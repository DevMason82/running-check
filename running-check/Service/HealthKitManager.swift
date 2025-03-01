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
    
    /// 오늘의 케이던스(분당 걸음 수) 데이터를 가져오는 함수
    func fetchTodayCadence() async throws -> Double {
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Date()

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, statistics, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sum = statistics?.sumQuantity()?.doubleValue(for: HKUnit.count()) else {
                    continuation.resume(returning: 0.0) // 데이터가 없으면 0 반환
                    return
                }

                // 시간(분)으로 나누어 케이던스 계산
                let elapsedMinutes = endDate.timeIntervalSince(startDate) / 60
                let cadence = sum / elapsedMinutes
                continuation.resume(returning: cadence)
            }
            self.healthStore.execute(query)
        }
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
        let predicate = HKQuery.predicateForWorkouts(with: .running)
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let locationPredicate = HKQuery.predicateForObjects(withMetadataKey: HKMetadataKeyIndoorWorkout, allowedValues: [false]) // 실외 필터
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, datePredicate, locationPredicate])

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKWorkoutType.workoutType(),
                predicate: compoundPredicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let workouts = samples as? [HKWorkout] else {
                    continuation.resume(returning: [])
                    return
                }

                let runs = workouts.map { workout -> RunData in
                    let distance = workout.totalDistance?.doubleValue(for: .meter()) ?? 0.0
                    let duration = workout.duration

                    // Use statistics(for:) to replace deprecated totalEnergyBurned
                    let calories = workout.statistics(for: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!)?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0.0

                    // 케이던스 계산 (총 스텝 / 총 시간(분))
                    let cadence = (workout.statistics(for: HKQuantityType.quantityType(forIdentifier: .stepCount)!)?.sumQuantity()?.doubleValue(for: .count()) ?? 0.0) / (duration / 60)

                    let pace = duration / (distance / 1000) // 초/킬로미터
                    return RunData(date: workout.startDate, duration: duration, distance: distance, calories: calories, pace: pace, cadence: cadence)
                }

                continuation.resume(returning: runs)
            }
            healthStore.execute(query)
        }
    }
    
    //    func fetchOutdoorRuns(startDate: Date, endDate: Date) async throws -> [RunData] {
    //        return try await fetchRunData(activityType: .running, locationType: .outdoor, startDate: startDate, endDate: endDate)
    //    }
    
    // 실내 달리기 워크아웃 데이터 가져오기
    func fetchIndoorRuns(startDate: Date, endDate: Date) async throws -> [RunData] {
        let predicate = HKQuery.predicateForWorkouts(with: .running)
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let locationPredicate = HKQuery.predicateForObjects(withMetadataKey: HKMetadataKeyIndoorWorkout, allowedValues: [true]) // 실내 필터
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, datePredicate, locationPredicate])

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKWorkoutType.workoutType(),
                predicate: compoundPredicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let workouts = samples as? [HKWorkout] else {
                    continuation.resume(returning: [])
                    return
                }

                let runs = workouts.map { workout -> RunData in
                    let distance = workout.totalDistance?.doubleValue(for: .meter()) ?? 0.0
                    let duration = workout.duration

                    // Use statistics(for:) to replace deprecated totalEnergyBurned
                    let calories = workout.statistics(for: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!)?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0.0

                    // 케이던스 계산 (총 스텝 / 총 시간(분))
                    let cadence = (workout.statistics(for: HKQuantityType.quantityType(forIdentifier: .stepCount)!)?.sumQuantity()?.doubleValue(for: .count()) ?? 0.0) / (duration / 60)

                    let pace = duration / (distance / 1000) // 초/킬로미터
                    return RunData(date: workout.startDate, duration: duration, distance: distance, calories: calories, pace: pace, cadence: cadence)
                }

                continuation.resume(returning: runs)
            }
            healthStore.execute(query)
        }
    }
    
//    func fetchIndoorRuns(startDate: Date, endDate: Date) async throws -> [RunData] {
//        return try await fetchRunData(activityType: .running, locationType: .indoor, startDate: startDate, endDate: endDate)
//    }
    
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
                        let date = workout.startDate
                        let duration = workout.duration
                        let distance = workout.totalDistance?.doubleValue(for: .meter()) ?? 0.0
                        let calories = try await self.fetchCaloriesForWorkout(workout)
                        let pace = distance > 0 ? (duration / distance * 1000) : 0 // 페이스 (초/km)
                        let cadence = await self.calculateCadence(for: workout)
                        
                        runData.append(
                            RunData(
                                date: date,
                                duration: duration,
                                distance: distance,
                                calories: calories,
                                pace: pace,
                                cadence: cadence
                                
//                                startDate: workout.startDate,
//                                endDate: workout.endDate
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
    
    // Cadence(스텝/분) 계산 함수
    func calculateCadence(for workout: HKWorkout) async -> Double {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return 0.0 // `stepCount` 데이터가 없는 경우 0 반환
        }
        
        // 워크아웃에 대한 Predicate 설정
        let predicate = HKQuery.predicateForObjects(from: workout)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepCountType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error = error {
                    print("Error fetching step count: \(error.localizedDescription)")
                    continuation.resume(returning: 0.0)
                    return
                }
                
                // 스텝 합계 가져오기
                let totalSteps = statistics?.sumQuantity()?.doubleValue(for: .count()) ?? 0.0
                
                // 워크아웃 시간을 분 단위로 계산
                let durationInMinutes = workout.duration / 60.0
                
                // 워크아웃 시간이 0인 경우 0 반환
                guard durationInMinutes > 0 else {
                    continuation.resume(returning: 0.0)
                    return
                }
                
                // 스텝/분 계산
                let cadence = totalSteps / durationInMinutes
                
                continuation.resume(returning: cadence)
            }
            
            // 쿼리 실행
            healthStore.execute(query)
        }
    }
    
    func fetchMonthlyAverageCadence() async throws -> Double {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            throw NSError(domain: "com.example.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to calculate the start of the month."])
        }

        // Fetch runs for the current month
        let (indoorRuns, outdoorRuns, _, _) = try await fetchRunsThisMonth()

        // Combine indoor and outdoor runs
        let allRuns = indoorRuns + outdoorRuns

        // Calculate average cadence
        guard !allRuns.isEmpty else {
            return 0.0 // No data available
        }

        let totalCadence = allRuns.reduce(0.0) { $0 + $1.cadence }
        let averageCadence = totalCadence / Double(allRuns.count)

        return averageCadence
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
                        let date = workout.startDate
                        let duration = workout.duration
                        let distance = workout.totalDistance?.doubleValue(for: .meter()) ?? 0.0
                        let calories = try await self.fetchCaloriesForWorkout(workout)
                        let pace = distance > 0 ? (duration / distance * 1000) : 0 // Pace in seconds per km
                        let cadence = await self.calculateCadence(for: workout)
                        
                        
                        let runData = RunData(
                            date: date,
                            duration: duration,
                            distance: distance,
                            calories: calories,
                            pace: pace,
                            cadence: cadence
                            
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
