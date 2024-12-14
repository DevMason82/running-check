//
//  CurrentMonthRunningReportViewModel.swift
//  running-check
//
//  Created by mason on 12/13/24.
//

import Foundation

@MainActor
class CurrentMonthRunningReportViewModel: ObservableObject {
    @Published var totalDistance: Double = 0.0
    @Published var totalCalories: Double = 0.0
    @Published var totalDuration: TimeInterval = 0.0
    @Published var averagePace: Double = 0.0
    @Published var averageCadence: Double = 0.0
    @Published var runCount: Int = 0
    @Published var errorMessage: String? = nil // 에러 메시지

    private let reportManager = CurrentMonthRunningReportManager()

    /// 이번 달 러닝 데이터를 가져오는 함수
    func fetchCurrentMonthReport() async {
        do {
            if let report = try await reportManager.generateCurrentMonthReport() {
                // 데이터를 업데이트
                self.totalDistance = report.totalDistance
                print(self.totalDistance)
                self.totalCalories = report.totalCalories
                self.totalDuration = report.totalDuration
                print(self.totalDuration)
                self.averagePace = report.averagePace
                self.averageCadence = report.averageCadence
                self.runCount = report.runCount
                self.errorMessage = nil // 에러 메시지 초기화
            } else {
                self.errorMessage = "이번 달 러닝 데이터가 없습니다."
            }
        } catch {
            self.errorMessage = "데이터를 가져오는 데 실패했습니다: \(error.localizedDescription)"
        }
    }
}
