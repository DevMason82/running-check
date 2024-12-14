//
//  CurrentMonthRunningReportManager.swift
//  running-check
//
//  Created by mason on 12/13/24.
//

import Foundation
import HealthKit

class CurrentMonthRunningReportManager {
    private let healthKitManager = HealthKitManager()
    private let calendar = Calendar.current

    func generateCurrentMonthReport() async throws -> RunningReport? {
        // 이번 달의 시작 날짜 계산
        let now = Date()
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            throw NSError(domain: "CurrentMonthRunningReportManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "이번 달 시작 날짜를 계산할 수 없습니다."])
        }
        let endOfMonth = now // 현재 날짜까지 계산

        // 이번 달 데이터 가져오기
        let (indoorRuns, outdoorRuns, _, _) = try await healthKitManager.fetchRuns(startDate: startOfMonth, endDate: endOfMonth)
        let allRuns = indoorRuns + outdoorRuns

        // 데이터가 없으면 nil 반환
        guard !allRuns.isEmpty else { return nil }

        // 통계 계산
        let totalDistance = allRuns.reduce(0.0) { $0 + $1.distance } / 1000.0 // km 단위
        let totalCalories = allRuns.reduce(0.0) { $0 + $1.calories }
        let totalDuration = allRuns.reduce(0.0) { $0 + $1.duration }
        let totalCadence = allRuns.reduce(0.0) { $0 + $1.cadence }
        let runCount = allRuns.count

        print("Total Distance (km): \(totalDistance)")
        print("Total Duration (seconds): \(totalDuration)")

        // 평균 페이스 계산 (초/킬로미터)
        let averagePace = totalDuration > 0 && totalDistance > 0
            ? totalDuration / totalDistance
            : 0.0

        // 디버그: 계산된 평균 페이스를 분과 초 형식으로 출력
        if averagePace > 0 {
            let minutes = Int(averagePace) / 60
            let seconds = Int(averagePace) % 60
            print("Calculated Average Pace: \(minutes)'\(String(format: "%02d", seconds))\"/km")
        } else {
            print("Calculated Average Pace: -")
        }

        // 평균 케이던스 계산
        let averageCadence = runCount > 0 ? totalCadence / Double(runCount) : 0.0

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

//class CurrentMonthRunningReportManager {
//    private let healthKitManager = HealthKitManager()
//    private let calendar = Calendar.current
//
//    func generateCurrentMonthReport() async throws -> RunningReport? {
//        // 이번 달의 시작과 끝 날짜 계산
//        let now = Date()
//        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
//            throw NSError(domain: "CurrentMonthRunningReportManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "이번 달 시작 날짜를 계산할 수 없습니다."])
//        }
//        let endOfMonth = now // 현재 날짜까지 계산
//
//        // 이번 달 데이터 가져오기
//        let (indoorRuns, outdoorRuns, _, _) = try await healthKitManager.fetchRuns(startDate: startOfMonth, endDate: endOfMonth)
//        let allRuns = indoorRuns + outdoorRuns
//
//        // 데이터가 없으면 nil 반환
//        guard !allRuns.isEmpty else { return nil }
//
//        // 통계 계산
//        let totalDistance = allRuns.reduce(0.0) { $0 + $1.distance } / 1000.0 // km 단위
//        let totalCalories = allRuns.reduce(0.0) { $0 + $1.calories }
//        let totalDuration = allRuns.reduce(0.0) { $0 + $1.duration }
//        let averagePace = totalDuration > 0 && totalDistance > 0
//            ? totalDuration / (totalDistance * 1000) // 초/킬로미터
//            : 0.0
//        let totalCadence = allRuns.reduce(0.0) { $0 + $1.cadence }
//        let averageCadence = totalCadence / Double(allRuns.count)
//        let runCount = allRuns.count
//
//        // 결과를 RunningReport 객체로 반환
//        return RunningReport(
//            totalDistance: totalDistance,
//            totalCalories: totalCalories,
//            totalDuration: totalDuration,
//            averagePace: averagePace, // Double 타입 반환
//            averageCadence: averageCadence,
//            runCount: runCount
//        )
//    }
//}
