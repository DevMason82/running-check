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
    @Published var runningDistance: Double = 0.0 // 러닝 거리 추가
    @Published var errorMessage: String?
    
    private let healthKitManager = HealthKitManager()
    
    // HealthKit 권한 요청
    func requestAuthorization() async {
        do {
            try await healthKitManager.requestAuthorization()
        } catch {
            self.errorMessage = "Failed to authorize HealthKit: \(error.localizedDescription)"
        }
    }
    
    // 칼로리 데이터 가져오기
    func fetchActiveCalories() async {
        do {
            let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())! // 최근 7일
            let endDate = Date()
            let calories = try await healthKitManager.fetchActiveCalories(startDate: startDate, endDate: endDate)
            self.activeCalories = calories
        } catch {
            self.errorMessage = "Failed to fetch calories: \(error.localizedDescription)"
        }
    }
    
    // 러닝 거리 데이터 가져오기
    func fetchRunningDistance() async {
        do {
            let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())! // 최근 7일
            let endDate = Date()
            let distance = try await healthKitManager.fetchRunningDistance(startDate: startDate, endDate: endDate)
            self.runningDistance = distance
        } catch {
            self.errorMessage = "Failed to fetch running distance: \(error.localizedDescription)"
        }
    }
    
    // 모든 데이터 가져오기 (칼로리 + 러닝 거리)
    func fetchAllHealthData() async {
        await fetchActiveCalories()
        await fetchRunningDistance()
    }
    
    // 미리보기용 ViewModel
    static var preview: HealthKitViewModel {
        let viewModel = HealthKitViewModel()
        viewModel.activeCalories = 350.0 // 테스트 데이터
        viewModel.runningDistance = 5000.0 // 테스트 데이터 (5km)
        return viewModel
    }
}
