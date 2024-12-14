//
//  PrevRunningReportManager.swift
//  running-check
//
//  Created by mason on 12/13/24.
//

import Foundation
import HealthKit

class PrevRunningReportManager {
    private let healthKitManager = HealthKitManager()
    private let calendar = Calendar.current

    func generateLastMonthReport() async throws -> RunningReport? {
        // 지난달의 시작과 끝 날짜 계산
        let now = Date()
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            throw NSError(domain: "PrevRunningReportManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "지난달 시작 날짜를 계산할 수 없습니다."])
        }
        let endOfLastMonth = calendar.date(byAdding: .day, value: -1, to: startOfMonth)!
        let startOfLastMonth = calendar.date(byAdding: .month, value: -1, to: startOfMonth)!

        // 지난달 데이터 가져오기
        let (indoorRuns, outdoorRuns, _, _) = try await healthKitManager.fetchRuns(startDate: startOfLastMonth, endDate: endOfLastMonth)
        let allRuns = indoorRuns + outdoorRuns

        // 데이터가 없으면 nil 반환
        guard !allRuns.isEmpty else { return nil }

        // 통계 계산
        let totalDistance = allRuns.reduce(0.0) { $0 + $1.distance } / 1000.0 // km 단위
        let totalCalories = allRuns.reduce(0.0) { $0 + $1.calories }
        let totalDuration = allRuns.reduce(0.0) { $0 + $1.duration }
        let runCount = allRuns.count

        // 평균 페이스 계산 (초/킬로미터)
        let averagePace = totalDuration > 0 && totalDistance > 0
            ? totalDuration / totalDistance
            : 0.0

        // 평균 케이던스 계산
        let totalCadence = allRuns.reduce(0.0) { $0 + $1.cadence }
        let averageCadence = runCount > 0 ? totalCadence / Double(runCount) : 0.0

        // 디버그 출력
        print("Last Month Report:")
        print("Total Distance (km): \(totalDistance)")
        print("Total Duration (seconds): \(totalDuration)")
        if averagePace > 0 {
            let minutes = Int(averagePace) / 60
            let seconds = Int(averagePace) % 60
            print("Average Pace: \(minutes)'\(String(format: "%02d", seconds))\"/km")
        } else {
            print("Average Pace: -")
        }
        print("Average Cadence: \(averageCadence) spm")
        print("Run Count: \(runCount)")

        // 결과를 RunningReport 객체로 반환
        return RunningReport(
            totalDistance: totalDistance,
            totalCalories: totalCalories,
            totalDuration: totalDuration,
            averagePace: averagePace,
            averageCadence: averageCadence,
            runCount: runCount
        )
    }
}


// 페이스를 "12'22\"" 형식으로 변환
//    private func formatPace(_ pace: Double) -> String {
//        let minutes = Int(pace) / 60
//        let seconds = Int(pace) % 60
//        return String(format: "%d'%02d\"", minutes, seconds)
//    }

extension HealthKitManager {
    /// 특정 기간 동안의 실내 및 실외 달리기 데이터를 가져옵니다.
    func fetchRuns(startDate: Date, endDate: Date) async throws -> (indoorRuns: [RunData], outdoorRuns: [RunData], indoorCount: Int, outdoorCount: Int) {
        async let indoorRuns = fetchIndoorRuns(startDate: startDate, endDate: endDate)
        async let outdoorRuns = fetchOutdoorRuns(startDate: startDate, endDate: endDate)

        let indoorRunData = try await indoorRuns
        let outdoorRunData = try await outdoorRuns

        return (
            indoorRuns: indoorRunData,
            outdoorRuns: outdoorRunData,
            indoorCount: indoorRunData.count,
            outdoorCount: outdoorRunData.count
        )
    }
}
