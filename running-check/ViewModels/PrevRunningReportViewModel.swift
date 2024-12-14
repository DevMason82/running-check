//
//  PrevRunningReportViewModel.swift
//  running-check
//
//  Created by mason on 12/13/24.
//

import Foundation

@MainActor
class PrevRunningReportViewModel: ObservableObject {
    @Published var totalDistance: Double = 0.0
    @Published var totalCalories: Double = 0.0
    @Published var totalDuration: TimeInterval = 0.0
    @Published var averagePace: Double = 0.0
    @Published var averageCadence: Double = 0.0
    @Published var runCount: Int = 0

    private let reportGenerator = PrevRunningReportManager()

    func fetchLastMonthReport() async {
        do {
            if let report = try await reportGenerator.generateLastMonthReport() {
                self.totalDistance = report.totalDistance
                self.totalCalories = report.totalCalories
                self.totalDuration = report.totalDuration
                self.averagePace = report.averagePace
                self.averageCadence = report.averageCadence
                self.runCount = report.runCount
            }
        } catch {
            print("Failed to fetch last month report: \(error.localizedDescription)")
        }
    }
}
