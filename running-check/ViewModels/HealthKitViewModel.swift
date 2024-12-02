//
//  HealthKitViewModel.swift
//  running-check
//
//  Created by mason on 11/30/24.
//

//import Foundation
//
//@MainActor
//class HealthKitViewModel: ObservableObject {
//    @Published var activeCalories: Double = 0.0
//    @Published var runningDistance: Double = 0.0
//    @Published var errorMessage: String?
//    
//    private let healthKitManager = HealthKitManager()
//    private let calendar = Calendar.current
//
//    // HealthKit 권한 요청
//    func requestAuthorization() async {
//        do {
//            try await healthKitManager.requestAuthorization()
//        } catch {
//            setError("Failed to authorize HealthKit: \(error.localizedDescription)")
//        }
//    }
//    
//    // 오늘 칼로리 데이터 가져오기
//    func fetchActiveCaloriesToday() async {
//        do {
//            let todayCalories = try await healthKitManager.fetchActiveCalories(startDate: startOfDay, endDate: Date())
//            self.activeCalories = todayCalories
//        } catch {
//            setError("Failed to fetch today's calories: \(error.localizedDescription)")
//        }
//    }
//    
//    // 오늘 러닝 거리 데이터 가져오기
//    func fetchRunningDistanceToday() async {
//        do {
//            let todayDistance = try await healthKitManager.fetchRunningDistance(startDate: startOfDay, endDate: Date())
//            self.runningDistance = todayDistance
//        } catch {
//            setError("Failed to fetch today's running distance: \(error.localizedDescription)")
//        }
//    }
//    
//    // 모든 데이터 가져오기 (오늘 기준)
//    func fetchAllHealthDataToday() async {
//        await fetchActiveCaloriesToday()
//        await fetchRunningDistanceToday()
//    }
//    
//    // 에러 메시지 설정
//    private func setError(_ message: String) {
//        DispatchQueue.main.async {
//            self.errorMessage = message
//        }
//    }
//
//    // 오늘의 시작 시간 계산
//    private var startOfDay: Date {
//        calendar.startOfDay(for: Date())
//    }
//    
//    // 미리보기용 ViewModel
//    static var preview: HealthKitViewModel {
//        let viewModel = HealthKitViewModel()
//        viewModel.activeCalories = 350.0
//        viewModel.runningDistance = 5000.0
//        return viewModel
//    }
//}

import Foundation
import HealthKit

@MainActor
class HealthKitViewModel: ObservableObject {
    @Published var activeCalories: Double = 0.0
    @Published var runningDistance: Double = 0.0
    @Published var outdoorRuns: [RunData] = [] // 실외 달리기
    @Published var indoorRuns: [RunData] = []  // 실내 달리기
    @Published var errorMessage: String?
    
    private let healthKitManager = HealthKitManager()
    private let calendar = Calendar.current

    // HealthKit 권한 요청
    func requestAuthorization() async {
        do {
            try await healthKitManager.requestAuthorization()
        } catch {
            setError("Failed to authorize HealthKit: \(error.localizedDescription)")
        }
    }
    
    // 오늘 칼로리 데이터 가져오기
    func fetchActiveCaloriesToday() async {
        do {
            let todayCalories = try await healthKitManager.fetchActiveCalories(startDate: startOfDay, endDate: Date())
            self.activeCalories = todayCalories
        } catch {
            setError("Failed to fetch today's calories: \(error.localizedDescription)")
        }
    }
    
    // 오늘 러닝 거리 데이터 가져오기
    func fetchRunningDistanceToday() async {
        do {
            let todayDistance = try await healthKitManager.fetchRunningDistance(startDate: startOfDay, endDate: Date())
            self.runningDistance = todayDistance
        } catch {
            setError("Failed to fetch today's running distance: \(error.localizedDescription)")
        }
    }
    
    // 오늘 실외 달리기 데이터 가져오기
    func fetchOutdoorRunsToday() async {
        do {
            let runs = try await healthKitManager.fetchOutdoorRuns(startDate: startOfDay, endDate: Date())
            self.outdoorRuns = runs
        } catch {
            setError("Failed to fetch today's outdoor runs: \(error.localizedDescription)")
        }
    }
    
    // 오늘 실내 달리기 데이터 가져오기
    func fetchIndoorRunsToday() async {
        do {
            let runs = try await healthKitManager.fetchIndoorRuns(startDate: startOfDay, endDate: Date())
            self.indoorRuns = runs
        } catch {
            setError("Failed to fetch today's indoor runs: \(error.localizedDescription)")
        }
    }
    
    // 모든 데이터 가져오기 (오늘 기준)
    func fetchAllHealthDataToday() async {
        await fetchActiveCaloriesToday()
        await fetchRunningDistanceToday()
        await fetchOutdoorRunsToday()
        await fetchIndoorRunsToday()
    }
    
    // 에러 메시지 설정
    private func setError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
        }
    }

    // 오늘의 시작 시간 계산
    private var startOfDay: Date {
        calendar.startOfDay(for: Date())
    }
    
    // 미리보기용 ViewModel
    static var preview: HealthKitViewModel {
        let viewModel = HealthKitViewModel()
        viewModel.activeCalories = 350.0
        viewModel.runningDistance = 5000.0
        viewModel.outdoorRuns = [
            RunData(
                duration: 3600,
                distance: 5000,
                calories: 300,
                pace: 7.2 * 60, // 7.2 min/km
                startDate: Date(),
                endDate: Date()
            )
        ]
        viewModel.indoorRuns = [
            RunData(
                duration: 1800,
                distance: 3000,
                calories: 200,
                pace: 6.0 * 60, // 6.0 min/km
                startDate: Date(),
                endDate: Date()
            )
        ]
        return viewModel
    }
}
