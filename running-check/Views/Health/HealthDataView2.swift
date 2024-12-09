//
//  HealthDataView.swift
//  running-check
//
//  Created by mason on 11/30/24.
//

import SwiftUI

struct HealthDataView2: View {
    let outdoorRuns: [RunData]
    let indoorRuns: [RunData]
    let indoorRunCount: [RunData]
    let outdoorRunCount: [RunData]
    
    var body: some View {
        VStack(alignment: .leading) {
            // 이번 달 러닝 횟수 섹션
            VStack(alignment: .leading, spacing: 10) {
                Text("이번 달 러닝 기록")
                    .font(.title2)
                    .bold()
//                    .padding(.bottom, 10)
                
                HStack {
                    Text("실외 러닝: \(outdoorRunCount.count)회")
                        .foregroundColor(.blue)
                        .font(.headline)
                    Spacer()
                    Text("실내 러닝: \(indoorRunCount.count)회")
                        .foregroundColor(.green)
                        .font(.headline)
                }
                
                //                                            let currentMonthOutdoorCount = countCurrentMonthRuns(runs: outdoorRuns)
                //                                            let currentMonthIndoorCount = countCurrentMonthRuns(runs: indoorRuns)
                //
                //                                            HStack {
                //                                                Text("실외 러닝: \(currentMonthOutdoorCount)회")
                //                                                    .foregroundColor(.blue)
                //                                                    .font(.headline)
                //                                                Spacer()
                //                                                Text("실내 러닝: \(currentMonthIndoorCount)회")
                //                                                    .foregroundColor(.green)
                //                                                    .font(.headline)
                //                                            }
                //                                            .padding(10)
                //                                            .background(Color.white.opacity(0.35))
                //                                            .cornerRadius(10)
            }
            .padding(.bottom, 20)
            
            HStack {
                // 실외 러닝 정보
                SectionView(runs: outdoorRuns, title: "실외 러닝", color: .blue)
                
                // 실내 러닝 정보
                SectionView(runs: indoorRuns, title: "실내 러닝", color: .green)
            }
            
            
        }
        .padding(.horizontal)
    }
    
    // 시간 포맷 함수
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return "\(hours):\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
        } else {
            return "\(minutes):\(String(format: "%02d", seconds))"
        }
    }
    
    // 이번 달 러닝 횟수 계산 함수
    private func countCurrentMonthRuns(runs: [RunData]) -> Int {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let currentMonth = calendar.component(.month, from: Date())
        
        return runs.filter {
            let runYear = calendar.component(.year, from: $0.startDate)
            let runMonth = calendar.component(.month, from: $0.startDate)
            return runYear == currentYear && runMonth == currentMonth
        }.count
    }
}

// Separate section view for clarity
struct SectionView: View {
    let runs: [RunData]
    let title: String
    let color: Color
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            let currentMonthCount = countCurrentMonthRuns(runs: runs)
            HStack {
                Text(title)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("\(currentMonthCount)회") // Int 값을 String으로 변환하고 "회"를 추가
                    .font(.subheadline)
                    .bold()
                //                        .foregroundColor(.gray)
            }
            if runs.isEmpty {
                VStack {
                    Text("기록이 없습니다.")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(10)
                .background(Color.white.opacity(0.35))
                .cornerRadius(10)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                let groupedRuns = groupRunsByMonth(runs: runs)
                ForEach(groupedRuns.sorted { $0.key > $1.key }, id: \.key) { month, runs in
                    //                    let isCurrentMonth = checkIfCurrentMonth(month: month)
                    //                    let currentMonthCount = isCurrentMonth ? countCurrentMonthRuns(runs: runs) : nil
                    
                    VStack(alignment: .leading, spacing: 10) {
                        // 월 표시 + 이번 달 러닝 횟수
                        //                        HStack {
                        //                            Text(formatMonth(month))
                        //                                .font(.headline)
                        //                                .bold()
                        //                                .foregroundColor(color)
                        //                            if let count = currentMonthCount {
                        //                                Text("(\(count)회)")
                        //                                    .font(.subheadline)
                        //                                    .foregroundColor(color)
                        //                            }
                        //                        }
                        //                        .padding(.bottom, 5)
                        
                        ForEach(runs, id: \.startDate) { run in
                            RunDetailView(run: run)
                        }
                    }
                }
            }
        }
    }
    // 이번 달 러닝 횟수 계산 함수
    private func countCurrentMonthRuns(runs: [RunData]) -> Int {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let currentMonth = calendar.component(.month, from: Date())
        
        return runs.filter {
            let runYear = calendar.component(.year, from: $0.startDate)
            let runMonth = calendar.component(.month, from: $0.startDate)
            return runYear == currentYear && runMonth == currentMonth
        }.count
    }
    
    private func groupRunsByMonth(runs: [RunData]) -> [String: [RunData]] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        
        return Dictionary(grouping: runs) { run in
            dateFormatter.string(from: run.startDate)
        }
    }
    
    private func formatMonth(_ month: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        guard let date = formatter.date(from: month) else { return month }
        
        // "yy년 MM월" 형식으로 변환
        formatter.dateFormat = "yy년 MM월"
        return formatter.string(from: date)
    }
    
    // 현재 월인지 확인
    private func checkIfCurrentMonth(month: String) -> Bool {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let currentMonth = calendar.component(.month, from: Date())
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        guard let date = formatter.date(from: month) else { return false }
        
        let components = calendar.dateComponents([.year, .month], from: date)
        return components.year == currentYear && components.month == currentMonth
    }
}

// View for displaying individual run details
struct RunDetailView: View {
    let run: RunData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text("운동 시간")
                    .font(.caption)
                    .bold()
                Text("\(formatDuration(run.duration))")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.yellow)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text("거리")
                    .font(.caption)
                    .bold()
                Text("\(run.distance / 1000, specifier: "%.2f") km")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text("칼로리")
                    .font(.caption)
                    .bold()
                Text("\(run.calories, specifier: "%.1f") kcal")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.red)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text("페이스")
                    .font(.caption)
                    .bold()
                Text("\(run.pace / 60, specifier: "%.2f")/km")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.mint)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background(Color.white.opacity(0.35))
        .cornerRadius(10)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return "\(hours):\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
        } else {
            return "\(minutes):\(String(format: "%02d", seconds))"
        }
    }
}

#Preview {
    HealthDataView2(outdoorRuns: [
        RunData(
            duration: 1800, // 30 minutes
            distance: 5000, // 5 km
            calories: 320.5,
            pace: 360, // 6 min/km
            startDate: Date(),
            endDate: Date()
        )
    ], indoorRuns: [
        RunData(
            duration: 1500, // 25 minutes
            distance: 3000, // 3 km
            calories: 200.0,
            pace: 300, // 5 min/km
            startDate: Date(),
            endDate: Date()
        )
    ],
                    indoorRunCount:[
                        RunData(
                            duration: 1500, // 25 minutes
                            distance: 3000, // 3 km
                            calories: 200.0,
                            pace: 300, // 5 min/km
                            startDate: Date(),
                            endDate: Date()
                        )
                    ],
                    outdoorRunCount: [
                        RunData(
                            duration: 1500, // 25 minutes
                            distance: 3000, // 3 km
                            calories: 200.0,
                            pace: 300, // 5 min/km
                            startDate: Date(),
                            endDate: Date()
                        )
                    ]
                    )
}

//import SwiftUI
//
//struct HealthDataView2: View {
//    let outdoorRuns: [RunData]
//    let indoorRuns: [RunData]
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            // 이번 달 러닝 횟수 섹션
//            VStack(alignment: .leading, spacing: 10) {
//                Text("이번 달 러닝 기록")
//                    .font(.title2)
//                    .bold()
//                    .padding(.bottom, 10)
//
//                let currentMonthOutdoorCount = countCurrentMonthRuns(runs: outdoorRuns)
//                let currentMonthIndoorCount = countCurrentMonthRuns(runs: indoorRuns)
//
//                HStack {
//                    Text("실외 러닝: \(currentMonthOutdoorCount)회")
//                        .foregroundColor(.blue)
//                        .font(.headline)
//                    Spacer()
//                    Text("실내 러닝: \(currentMonthIndoorCount)회")
//                        .foregroundColor(.green)
//                        .font(.headline)
//                }
//                .padding(10)
//                .background(Color.white.opacity(0.35))
//                .cornerRadius(10)
//            }
//            .padding(.bottom, 20)
//
//            HStack(alignment: .top, spacing: 20) {
//                // 실외 러닝 정보
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("실외 러닝")
//                        .font(.headline)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//
//                    if outdoorRuns.isEmpty {
//                        VStack {
//                            Text("기록이 없습니다.")
//                                .foregroundColor(.gray)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                        }
//                        .padding(10)
//                        .background(Color.white.opacity(0.35))
//                        .cornerRadius(10)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    } else {
//                        ForEach(groupRunsByMonth(runs: outdoorRuns).sorted(by: >), id: \.key) { month, runs in
//                            VStack(alignment: .leading, spacing: 10) {
//                                Text(formatMonth(month))
//                                    .font(.headline)
//                                    .bold()
//                                    .foregroundColor(isCurrentMonth(month) ? .blue : .primary)
//                                    .padding(.bottom, 5)
//
//                                ForEach(runs, id: \.startDate) { run in
//                                    VStack(alignment: .leading, spacing: 8) {
//                                        VStack(alignment: .leading, spacing: 2) {
//                                            Text("운동 시간")
//                                                .font(.caption)
//                                                .bold()
//                                            Text("\(formatDuration(run.duration))")
//                                                .font(.title2)
//                                                .bold()
//                                                .foregroundColor(.yellow)
//                                        }
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//                                        VStack(alignment: .leading, spacing: 2) {
//                                            Text("거리")
//                                                .font(.caption)
//                                                .bold()
//                                            Text("\(run.distance / 1000, specifier: "%.2f") km")
//                                                .font(.title2)
//                                                .bold()
//                                                .foregroundColor(.blue)
//                                        }
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//                                        VStack(alignment: .leading, spacing: 2) {
//                                            Text("칼로리")
//                                                .font(.caption)
//                                                .bold()
//                                            Text("\(run.calories, specifier: "%.1f") kcal")
//                                                .font(.title2)
//                                                .bold()
//                                                .foregroundColor(.red)
//                                        }
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//                                        VStack(alignment: .leading, spacing: 2) {
//                                            Text("페이스")
//                                                .font(.caption)
//                                                .bold()
//                                            Text("\(run.pace / 60, specifier: "%.2f")/km")
//                                                .font(.title2)
//                                                .bold()
//                                                .foregroundColor(.mint)
//                                        }
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//                                    }
//                                    .padding(10)
//                                    .background(Color.white.opacity(0.35))
//                                    .cornerRadius(10)
//                                }
//                            }
//                        }
//                    }
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//
//                // 실내 러닝 정보
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("실내 러닝")
//                        .font(.headline)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//
//                    if indoorRuns.isEmpty {
//                        VStack {
//                            Text("기록이 없습니다.")
//                                .foregroundColor(.gray)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                        }
//                        .padding(10)
//                        .background(Color.white.opacity(0.35))
//                        .cornerRadius(10)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    } else {
//                        ForEach(groupRunsByMonth(runs: indoorRuns).sorted(by: >), id: \.key) { month, runs in
//                            VStack(alignment: .leading, spacing: 10) {
//                                Text(formatMonth(month))
//                                    .font(.headline)
//                                    .bold()
//                                    .foregroundColor(isCurrentMonth(month) ? .green : .primary)
//                                    .padding(.bottom, 5)
//
//                                ForEach(runs, id: \.startDate) { run in
//                                    VStack(alignment: .leading, spacing: 8) {
//                                        VStack(alignment: .leading, spacing: 2) {
//                                            Text("운동 시간")
//                                                .font(.caption)
//                                                .bold()
//                                            Text("\(formatDuration(run.duration))")
//                                                .font(.title2)
//                                                .bold()
//                                                .foregroundColor(.yellow)
//                                        }
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//                                        VStack(alignment: .leading, spacing: 2) {
//                                            Text("거리")
//                                                .font(.caption)
//                                                .bold()
//                                            Text("\(run.distance / 1000, specifier: "%.2f") km")
//                                                .font(.title2)
//                                                .bold()
//                                                .foregroundColor(.blue)
//                                        }
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//                                        VStack(alignment: .leading, spacing: 2) {
//                                            Text("칼로리")
//                                                .font(.caption)
//                                                .bold()
//                                            Text("\(run.calories, specifier: "%.1f") kcal")
//                                                .font(.title2)
//                                                .bold()
//                                                .foregroundColor(.red)
//                                        }
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//                                        VStack(alignment: .leading, spacing: 2) {
//                                            Text("페이스")
//                                                .font(.caption)
//                                                .bold()
//                                            Text("\(run.pace / 60, specifier: "%.2f")/km")
//                                                .font(.title2)
//                                                .bold()
//                                                .foregroundColor(.mint)
//                                        }
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//                                    }
//                                    .padding(10)
//                                    .background(Color.white.opacity(0.35))
//                                    .cornerRadius(10)
//                                }
//                            }
//                        }
//                    }
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//            }
//            .frame(maxWidth: .infinity)
//        }
//        .padding(.horizontal)
//    }
//
//    // 시간 포맷 함수
//    private func formatDuration(_ duration: TimeInterval) -> String {
//        let hours = Int(duration) / 3600
//        let minutes = (Int(duration) % 3600) / 60
//        let seconds = Int(duration) % 60
//
//        if hours > 0 {
//            return "\(hours):\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
//        } else {
//            return "\(minutes):\(String(format: "%02d", seconds))"
//        }
//    }
//
//    // 이번 달 러닝 횟수 계산 함수
//    private func countCurrentMonthRuns(runs: [RunData]) -> Int {
//        let calendar = Calendar.current
//        let currentYear = calendar.component(.year, from: Date())
//        let currentMonth = calendar.component(.month, from: Date())
//
//        return runs.filter {
//            let runYear = calendar.component(.year, from: $0.startDate)
//            let runMonth = calendar.component(.month, from: $0.startDate)
//            return runYear == currentYear && runMonth == currentMonth
//        }.count
//    }
//
//    // 러닝 데이터를 월별로 그룹화
//    private func groupRunsByMonth(runs: [RunData]) -> [String: [RunData]] {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM"
//
//        return Dictionary(grouping: runs) { run in
//            dateFormatter.string(from: run.startDate)
//        }
//    }
//
//    // 월 포맷
//    private func formatMonth(_ month: String) -> String {
//        let currentMonth = Calendar.current.component(.month, from: Date())
//        let currentYear = Calendar.current.component(.year, from: Date())
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM"
//        guard let date = formatter.date(from: month) else { return month }
//
//        let monthYear = Calendar.current.dateComponents([.month, .year], from: date)
//        if monthYear.month == currentMonth && monthYear.year == currentYear {
//            return "이번 달"
//        } else {
//            formatter.dateFormat = "MMM yyyy"
//            return formatter.string(from: date)
//        }
//    }
//
//    // 현재 월인지 확인
//    private func isCurrentMonth(_ month: String) -> Bool {
//        let currentMonth = Calendar.current.component(.month, from: Date())
//        let currentYear = Calendar.current.component(.year, from: Date())
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM"
//        guard let date = formatter.date(from: month) else { return false }
//
//        let monthYear = Calendar.current.dateComponents([.month, .year], from: date)
//        return monthYear.month == currentMonth && monthYear.year == currentYear
//    }
//}
//
//#Preview {
//    HealthDataView2(outdoorRuns: [
//        RunData(
//            duration: 1800, // 30 minutes
//            distance: 5000, // 5 km
//            calories: 320.5,
//            pace: 360, // 6 min/km
//            startDate: Date(), // Current month
//            endDate: Date()
//        )
//    ], indoorRuns: [
//        RunData(
//            duration: 1500, // 25 minutes
//            distance: 3000, // 3 km
//            calories: 200.0,
//            pace: 300, // 5 min/km
//            startDate: Date(), // Current month
//            endDate: Date()
//        )
//    ])
//}
