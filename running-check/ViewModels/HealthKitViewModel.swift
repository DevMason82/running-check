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
    private let healthKitManager = HealthKitManager()
    
    @Published var activeCalories: Double = 0.0
    @Published var runningDistance: Double = 0.0
    @Published var outdoorRuns: [RunData] = [] // 실외 달리기
    @Published var indoorRuns: [RunData] = []  // 실내 달리기
    @Published var allIndoorRunsThisMonth: [RunData] = [] // 이번 달 실내 달리기
    @Published var allOutdoorRunsThisMonth: [RunData] = [] // 이번 달 실외 달리기
    @Published var indoorRunCount: Int = 0 // 실내 달리기 개수
    @Published var outdoorRunCount: Int = 0 // 실외 달리기 개수
    @Published var errorMessage: String?
    
    @Published var totalRunningDistance: Double = 0.0
    @Published var totalCaloriesBurned: Double = 0.0
    @Published var totalRunningTime: TimeInterval = 0.0
    @Published var averagePace: Double = 0.0 // 초/킬로미터
    @Published var averageCadence: Double = 0.0 // 스텝/분
    @Published var currentMonth: String = ""
    
    
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
    
    func fetchMonthlyData() async {
            do {
                // 현재 달 이름
                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "yy-MM"
                dateFormatter.dateFormat = "yy년 M월"
                currentMonth = dateFormatter.string(from: Date())
                
                let (indoorRuns, outdoorRuns, indoorCount, outdoorCount) = try await healthKitManager.fetchRunsThisMonth()
                
                // 총 러닝 데이터
                let allRuns = indoorRuns + outdoorRuns
                
                totalRunningDistance = allRuns.reduce(0) { $0 + $1.distance } / 1000.0 // Convert to km
                totalCaloriesBurned = allRuns.reduce(0) { $0 + $1.calories }
                totalRunningTime = allRuns.reduce(0) { $0 + $1.duration }
                
                // 평균 페이스 (초/킬로미터)
                let totalPace = allRuns.reduce(0) { $0 + $1.pace }
                averagePace = allRuns.count > 0 ? totalPace / Double(allRuns.count) : 0
                
                // 평균 케이던스 계산 (예제 데이터)
                let totalCadence = allRuns.reduce(0) { $0 + $1.cadence } // $1.cadence 사용
                averageCadence = allRuns.count > 0 ? totalCadence / Double(allRuns.count) : 0
                
                indoorRunCount = indoorCount
                outdoorRunCount = outdoorCount
            } catch {
                print("Error fetching monthly data: \(error.localizedDescription)")
            }
        }
    
    // 모든 데이터 가져오기 (오늘 기준)
    func fetchAllHealthDataToday() async {
        await fetchActiveCaloriesToday()
        await fetchRunningDistanceToday()
        await fetchOutdoorRunsToday()
        await fetchIndoorRunsToday()
        await fetchRunsThisMonth() // Include monthly runs
        await fetchMonthlyData()
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
    
    static var preview: HealthKitViewModel {
        let viewModel = HealthKitViewModel()
        viewModel.totalRunningDistance = 42.195 // 샘플 러닝 거리 (42.195km)
        viewModel.totalCaloriesBurned = 3000 // 샘플 소모 칼로리
        viewModel.totalRunningTime = 3600 * 5 + 30 * 60 // 5시간 30분
        viewModel.averagePace = 360 // 6분/km
        viewModel.averageCadence = 180 // 180 spm
        viewModel.indoorRunCount = 3 // 샘플 실내 러닝 횟수
        viewModel.outdoorRunCount = 5 // 샘플 실외 러닝 횟수
        viewModel.currentMonth = "12월" // 샘플 현재 달
        return viewModel
    }
}
