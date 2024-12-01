//
//  HealthKitManager.swift
//  running-check
//
//  Created by mason on 11/30/24.
//

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
    
    // 칼로리 소모 데이터 가져오기
    func fetchActiveCalories(startDate: Date, endDate: Date) async throws -> Double {
        return try await fetchQuantityData(
            typeIdentifier: .activeEnergyBurned,
            startDate: startDate,
            endDate: endDate,
            unit: .kilocalorie()
        )
    }
    
    // 러닝 거리 데이터 가져오기
    func fetchRunningDistance(startDate: Date, endDate: Date) async throws -> Double {
        return try await fetchQuantityData(
            typeIdentifier: .distanceWalkingRunning,
            startDate: startDate,
            endDate: endDate,
            unit: .meter()
        )
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

                continuation.resume(returning: totalValue) // 총합 반환
            }

            healthStore.execute(query)
        }
    }
}
