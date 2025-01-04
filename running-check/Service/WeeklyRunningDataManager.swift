//
//  WeeklyRunningDataManager.swift
//  running-check
//
//  Created by mason on 1/1/25.
//

import Foundation
import HealthKit

class WeeklyRunningDataManager {
//    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()
    
    // 주간 러닝 데이터 가져오기
    func fetchWeeklyRunningData() async throws -> [HKWorkout] {
        let calendar = Calendar.current
        let now = Date()
        
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start else {
            throw NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "주간 시작 날짜 오류"])
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfWeek, end: now, options: .strictStartDate)
        let workoutType = HKObjectType.workoutType()
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: workoutType,
                                      predicate: predicate,
                                      limit: HKObjectQueryNoLimit,
                                      sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, samples, error in
                
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let samples = samples as? [HKWorkout] {
                    let runningWorkouts = samples.filter { $0.workoutActivityType == .running }
                    continuation.resume(returning: runningWorkouts)
                } else {
                    continuation.resume(returning: [])
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    // 주간 평균 케이던스 가져오기
//    func fetchWeeklyAverageCadence(completion: @escaping (Double?, Error?) -> Void) {
//        fetchWeeklyRunningData { [weak self] workouts, error in
//            guard let self = self, let workouts = workouts, error == nil else {
//                completion(nil, error)
//                return
//            }
//            
//            Task {
//                var totalCadence: Double = 0
//                var runCount: Int = 0
//                
//                for workout in workouts {
//                    let cadence = await self.calculateCadence(for: workout)
//                    totalCadence += cadence
//                    runCount += 1
//                }
//                
//                let averageCadence = runCount > 0 ? totalCadence / Double(runCount) : 0
//                DispatchQueue.main.async {
//                    completion(averageCadence, nil)
//                }
//            }
//        }
//    }
    
    func fetchWeeklyAverageCadence() async throws -> Double {
        let workouts = try await fetchWeeklyRunningData()  // 주간 러닝 데이터 호출
        
        var totalCadence: Double = 0
        var runCount: Int = 0
        
        for workout in workouts {
            let cadence = await calculateCadence(for: workout)  // 개별 워크아웃에서 케이던스 계산
            totalCadence += cadence
            runCount += 1
        }
        
        return runCount > 0 ? totalCadence / Double(runCount) : 0
    }

    // 케이던스 계산 (비동기)
    func calculateCadence(for workout: HKWorkout) async -> Double {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return 0.0
        }
        
        let predicate = HKQuery.predicateForObjects(from: workout)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepCountType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                guard let sum = statistics?.sumQuantity()?.doubleValue(for: .count()), error == nil else {
                    continuation.resume(returning: 0)
                    return
                }
                
                let durationInMinutes = workout.duration / 60.0
                let cadence = durationInMinutes > 0 ? sum / durationInMinutes : 0
                
                continuation.resume(returning: cadence)
            }
            
            healthStore.execute(query)
        }
    }
}
