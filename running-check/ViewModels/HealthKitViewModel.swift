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

@MainActor
class HealthKitViewModel: ObservableObject {
    @Published var activeCalories: Double = 0.0
    @Published var runningDistance: Double = 0.0
    @Published var outdoorRuns: [RunData] = [] // 실외 달리기
    @Published var indoorRuns: [RunData] = []  // 실내 달리기
    @Published var allIndoorRunsThisMonth: [RunData] = [] // 이번 달 실내 달리기
    @Published var allOutdoorRunsThisMonth: [RunData] = [] // 이번 달 실외 달리기
    @Published var indoorRunCount: Int = 0 // 실내 달리기 개수
    @Published var outdoorRunCount: Int = 0 // 실외 달리기 개수
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
            print("칼로리", self.activeCalories)
        } catch {
            setError("Failed to fetch today's calories: \(error.localizedDescription)")
        }
    }
    
    // 오늘 러닝 거리 데이터 가져오기
    func fetchRunningDistanceToday() async {
        do {
            let todayDistance = try await healthKitManager.fetchRunningDistance(startDate: startOfDay, endDate: Date())
            self.runningDistance = todayDistance
            print("거리", self.runningDistance)
        } catch {
            setError("Failed to fetch today's running distance: \(error.localizedDescription)")
        }
    }
    
    // 오늘 실외 달리기 데이터 가져오기
    func fetchOutdoorRunsToday() async {
        do {
            let runs = try await healthKitManager.fetchOutdoorRuns(startDate: startOfDay, endDate: Date())
            self.outdoorRuns = runs
            print("실외", self.outdoorRuns)
        } catch {
            setError("Failed to fetch today's outdoor runs: \(error.localizedDescription)")
        }
    }
    
    // 오늘 실내 달리기 데이터 가져오기
    func fetchIndoorRunsToday() async {
        do {
            let runs = try await healthKitManager.fetchIndoorRuns(startDate: startOfDay, endDate: Date())
            self.indoorRuns = runs
            print("실내", self.indoorRuns)
        } catch {
            setError("Failed to fetch today's indoor runs: \(error.localizedDescription)")
        }
    }
    
    // 이번 달 실내/실외 달리기 데이터 가져오기
    func fetchRunsThisMonth() async {
        do {
            let (indoorRuns, outdoorRuns, indoorCount, outdoorCount) = try await healthKitManager.fetchRunsThisMonth()
            self.allIndoorRunsThisMonth = indoorRuns
            self.allOutdoorRunsThisMonth = outdoorRuns
            self.indoorRunCount = indoorCount
            self.outdoorRunCount = outdoorCount
            print("이번 달 실내 달리기 개수: \(indoorCount), 실외 달리기 개수: \(outdoorCount)")
        } catch {
            setError("Failed to fetch runs for this month: \(error.localizedDescription)")
        }
    }
    
    // 모든 데이터 가져오기 (오늘 기준)
    func fetchAllHealthDataToday() async {
        await fetchActiveCaloriesToday()
        await fetchRunningDistanceToday()
        await fetchOutdoorRunsToday()
        await fetchIndoorRunsToday()
        await fetchRunsThisMonth() // Include monthly runs
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
        viewModel.activeCalories = 450.5
        viewModel.runningDistance = 7321.4 // 7.32 km
        viewModel.outdoorRuns = [
            RunData(
                duration: 1800, // 30 minutes
                distance: 5000, // 5 km
                calories: 320.5,
                pace: 360, // 6 min/km
                startDate: Date(),
                endDate: Date()
            )
        ]
        viewModel.indoorRuns = [
            RunData(
                duration: 1500, // 25 minutes
                distance: 3000, // 3 km
                calories: 200.0,
                pace: 300, // 5 min/km
                startDate: Date(),
                endDate: Date()
            )
        ]
        viewModel.allIndoorRunsThisMonth = [
            RunData(
                duration: 1500, // 25 minutes
                distance: 3000, // 3 km
                calories: 200.0,
                pace: 300, // 5 min/km
                startDate: Date(),
                endDate: Date()
            )
        ]
        viewModel.allOutdoorRunsThisMonth = [
            RunData(
                duration: 1800, // 30 minutes
                distance: 5000, // 5 km
                calories: 320.5,
                pace: 360, // 6 min/km
                startDate: Date(),
                endDate: Date()
            )
        ]
        viewModel.indoorRunCount = 1
        viewModel.outdoorRunCount = 1
        return viewModel
    }
}
