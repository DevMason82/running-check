//
//  HealthKitViewModel.swift
//  running-check
//
//  Created by mason on 11/30/24.
//

import Foundation

@MainActor
class HealthKitViewModel: ObservableObject {
    @Published var activeCalories: Double = 0.0
    @Published var runningDistance: Double = 0.0
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
    
    // 모든 데이터 가져오기 (오늘 기준)
    func fetchAllHealthDataToday() async {
        await fetchActiveCaloriesToday()
        await fetchRunningDistanceToday()
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
        return viewModel
    }
}
