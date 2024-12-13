//
//  PrevRunningReportViewModel.swift
//  running-check
//
//  Created by mason on 12/13/24.
//

import Foundation

@MainActor
class PrevRunningReportViewModel: ObservableObject {
    @Published var lastMonthReport: String = ""

    private let reportGenerator = PrevRunningReportManager()

    func fetchLastMonthReport() async {
        self.lastMonthReport = await reportGenerator.generateLastMonthReport()
    }
}
