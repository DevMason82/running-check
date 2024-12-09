import Foundation
import HealthKit

class HealthKitManager {
    let healthStore = HKHealthStore()
    
    // HealthKit 권한 요청
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw NSError(domain: "com.example.healthkit", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device."])
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!, // 러닝 거리
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,    // 칼로리 소모
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,    // 운동 시간
            HKObjectType.workoutType() // 워크아웃
        ]
        
        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
    }
    
    // 오늘 칼로리 소모 데이터 가져오기
    func fetchActiveCaloriesToday() async throws -> Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        return try await fetchActiveCalories(startDate: startOfDay, endDate: now)
    }
    
    // 특정 기간 동안의 칼로리 소모 데이터 가져오기
    func fetchActiveCalories(startDate: Date, endDate: Date) async throws -> Double {
        return try await fetchQuantityData(
            typeIdentifier: .activeEnergyBurned,
            startDate: startDate,
            endDate: endDate,
            unit: .kilocalorie()
        )
    }
    
    // 특정 기간 동안의 러닝 거리 데이터 가져오기
//    func fetchRunningDistance(startDate: Date, endDate: Date) async throws -> Double {
//        return try await fetchQuantityData(
//            typeIdentifier: .distanceWalkingRunning,
//            startDate: startDate,
//            endDate: endDate,
//            unit: .meter()
//        )
//    }
    
    // 특정 기간 동안의 달리기 거리 데이터 가져오기
    func fetchRunningDistance(startDate: Date, endDate: Date) async throws -> Double {
        let runningPredicate = HKQuery.predicateForWorkouts(with: .running)
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [runningPredicate, datePredicate])

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKWorkoutType.workoutType(),
                predicate: compoundPredicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { (_, samples, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let workouts = samples as? [HKWorkout] else {
                    continuation.resume(returning: 0.0) // 데이터가 없으면 0 반환
                    return
                }

                let totalDistance = workouts.reduce(0.0) { sum, workout in
                    sum + (workout.totalDistance?.doubleValue(for: .meter()) ?? 0.0)
                }

                continuation.resume(returning: totalDistance)
            }
            healthStore.execute(query)
        }
    }
    
    // 실외 달리기 워크아웃 데이터 가져오기
    func fetchOutdoorRuns(startDate: Date, endDate: Date) async throws -> [RunData] {
        return try await fetchRunData(activityType: .running, locationType: .outdoor, startDate: startDate, endDate: endDate)
    }
    
    // 실내 달리기 워크아웃 데이터 가져오기
    func fetchIndoorRuns(startDate: Date, endDate: Date) async throws -> [RunData] {
        return try await fetchRunData(activityType: .running, locationType: .indoor, startDate: startDate, endDate: endDate)
    }
    
    // 공통 런 데이터 가져오기 함수
    private func fetchRunData(
        activityType: HKWorkoutActivityType,
        locationType: HKWorkoutSessionLocationType,
        startDate: Date,
        endDate: Date
    ) async throws -> [RunData] {
        let activityPredicate = HKQuery.predicateForWorkouts(with: activityType)
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let locationPredicate = locationType == .indoor
            ? HKQuery.predicateForObjects(withMetadataKey: HKMetadataKeyIndoorWorkout, allowedValues: [true])
            : HKQuery.predicateForObjects(withMetadataKey: HKMetadataKeyIndoorWorkout, allowedValues: [false])
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [activityPredicate, datePredicate, locationPredicate])

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKWorkoutType.workoutType(),
                predicate: compoundPredicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { [weak self] (_, samples, error) in
                guard let self = self else { return }
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let workouts = samples as? [HKWorkout] else {
                    continuation.resume(returning: [])
                    return
                }

                Task {
                    var runData: [RunData] = []
                    for workout in workouts {
                        let duration = workout.duration
                        let distance = workout.totalDistance?.doubleValue(for: .meter()) ?? 0.0
                        let calories = try await self.fetchCaloriesForWorkout(workout)
                        let pace = distance > 0 ? (duration / distance * 1000) : 0 // 페이스 (초/km)
                        
                        runData.append(
                            RunData(
                                duration: duration,
                                distance: distance,
                                calories: calories,
                                pace: pace,
                                startDate: workout.startDate,
                                endDate: workout.endDate
                            )
                        )
                    }
                    continuation.resume(returning: runData)
                }
            }
            healthStore.execute(query)
        }
    }
    
    // 칼로리 데이터 가져오기
    private func fetchCaloriesForWorkout(_ workout: HKWorkout) async throws -> Double {
        guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            throw NSError(domain: "com.example.healthkit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Active Energy Burned type unavailable"])
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let statisticsQuery = HKStatisticsQuery(
                quantityType: energyType,
                quantitySamplePredicate: HKQuery.predicateForObjects(from: workout)
            ) { (_, statistics, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let totalEnergyBurned = statistics?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0.0
                continuation.resume(returning: totalEnergyBurned)
            }
            healthStore.execute(statisticsQuery)
        }
    }
    
    // 공통 데이터 가져오기 함수
    private func fetchQuantityData(
        typeIdentifier: HKQuantityTypeIdentifier,
        startDate: Date,
        endDate: Date,
        unit: HKUnit
    ) async throws -> Double {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: typeIdentifier) else {
            throw NSError(domain: "com.example.healthkit", code: 1, userInfo: [NSLocalizedDescriptionKey: "\(typeIdentifier.rawValue) type unavailable"])
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: quantityType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { (_, samples, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let samples = samples as? [HKQuantitySample] else {
                    continuation.resume(returning: 0.0) // 데이터가 없는 경우 0 반환
                    return
                }

                let totalValue = samples.reduce(0.0) { sum, sample in
                    sum + sample.quantity.doubleValue(for: unit)
                }

                continuation.resume(returning: totalValue)
            }
            healthStore.execute(query)
        }
    }
    
    // Function to fetch all runs for the current month and count them by type
    func fetchRunsThisMonth() async throws -> (indoorRuns: [RunData], outdoorRuns: [RunData], indoorCount: Int, outdoorCount: Int) {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            throw NSError(domain: "com.example.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to calculate the start of the month."])
        }

        let datePredicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: now, options: .strictStartDate)
        let runningPredicate = HKQuery.predicateForWorkouts(with: .running)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, runningPredicate])

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKWorkoutType.workoutType(),
                predicate: compoundPredicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { [weak self] (_, samples, error) in
                guard let self = self else { return }
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let workouts = samples as? [HKWorkout] else {
                    continuation.resume(returning: ([], [], 0, 0)) // No data available
                    return
                }

                Task {
                    var indoorRuns: [RunData] = []
                    var outdoorRuns: [RunData] = []
                    var indoorCount = 0
                    var outdoorCount = 0

                    for workout in workouts {
                        let duration = workout.duration
                        let distance = workout.totalDistance?.doubleValue(for: .meter()) ?? 0.0
                        let calories = try await self.fetchCaloriesForWorkout(workout)
                        let pace = distance > 0 ? (duration / distance * 1000) : 0 // Pace in seconds per km

                        let runData = RunData(
                            duration: duration,
                            distance: distance,
                            calories: calories,
                            pace: pace,
                            startDate: workout.startDate,
                            endDate: workout.endDate
                        )

                        if let isIndoor = workout.metadata?[HKMetadataKeyIndoorWorkout] as? Bool {
                            if isIndoor {
                                indoorRuns.append(runData)
                                indoorCount += 1
                            } else {
                                outdoorRuns.append(runData)
                                outdoorCount += 1
                            }
                        } else {
                            // If metadata is unavailable, classify as outdoor by default
                            outdoorRuns.append(runData)
                            outdoorCount += 1
                        }
                    }

                    continuation.resume(returning: (indoorRuns, outdoorRuns, indoorCount, outdoorCount))
                }
            }
            healthStore.execute(query)
        }
    }
    
    // Function to count indoor and outdoor runs for the current month
    func countIndoorOutdoorRunsThisMonth() async throws -> (indoorRuns: Int, outdoorRuns: Int) {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            throw NSError(domain: "com.example.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to calculate the start of the month."])
        }

        let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: now, options: .strictStartDate)
        let workoutType = HKWorkoutType.workoutType()

        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, samples, error in
            if let error = error {
                print("Error fetching workouts: \(error.localizedDescription)")
                return
            }

            guard let workouts = samples as? [HKWorkout] else {
                print("No workouts found.")
                return
            }

            var indoorCount = 0
            var outdoorCount = 0

            for workout in workouts {
                if workout.workoutActivityType == .running {
                    if let isIndoor = workout.metadata?[HKMetadataKeyIndoorWorkout] as? Bool {
                        if isIndoor {
                            indoorCount += 1
                        } else {
                            outdoorCount += 1
                        }
                    } else {
                        // If metadata is unavailable, consider it outdoor by default
                        outdoorCount += 1
                    }
                }
            }

            print("Indoor Runs: \(indoorCount), Outdoor Runs: \(outdoorCount)")
        }

        healthStore.execute(query)

        // Return counts (dummy values here as query runs asynchronously)
        return (0, 0) // Update this with actual counts once asynchronous fetching is handled
    }
}

// 런 데이터 구조체
struct RunData {
    let duration: TimeInterval   // 운동 시간 (초 단위)
    let distance: Double         // 거리 (미터)
    let calories: Double         // 칼로리 (킬로칼로리)
    let pace: Double             // 페이스 (초/km)
    let startDate: Date          // 운동 시작 시간
    let endDate: Date            // 운동 종료 시간
}




