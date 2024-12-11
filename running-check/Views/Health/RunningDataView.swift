//
//  RunningDataView.swift
//  running-check
//
//  Created by mason on 11/30/24.
//

import SwiftUI

struct RunningDataView: View {
    let outdoorRuns: [RunData]
    let indoorRuns: [RunData]
    let indoorRunCount: [RunData]
    let outdoorRunCount: [RunData]
    
    var body: some View {
        VStack(alignment: .leading) {
            // 이번 달 러닝 횟수 섹션
            VStack(alignment: .leading, spacing: 10) {
                Text("\(formattedCurrentMonthYear()) 러닝 기록")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color("CardFontColor"))
                
                HStack {
                    Image(systemName: "figure.run")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(Color("CardFontColor"))
                    Text("실외 러닝")
                        .font(.headline)
                        .foregroundColor(Color("CardFontColor"))
                    Text("\(outdoorRunCount.count)회")
                        .bold()
                        .foregroundColor(Color("CardFontColor"))
                        .font(.system(size: 20))
                    
                    Spacer()
                    
                    Image(systemName: "figure.run.treadmill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(Color("CardFontColor"))
                    Text("실내 러닝")
                        .foregroundColor(Color("CardFontColor"))
                        .font(.headline)
                    Text("\(indoorRunCount.count)회")
                        .bold()
                        .foregroundColor(Color("CardFontColor"))
                        .font(.system(size: 20))
                }
                .cornerRadius(10)
            }
            .padding(.bottom, 20)
            
            HStack(alignment: .top) {
                // 실외 러닝 정보
                SectionView(runs: outdoorRuns, title: "\(formattedCurrentDay()) 실외 러닝")
                
                // 실내 러닝 정보
                SectionView(runs: indoorRuns, title: "\(formattedCurrentDay()) 실내 러닝")
            }
            .padding(.leading, 15)
            
            
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
    
    // 현재 년과 월을 포맷하는 함수
    private func formattedCurrentMonthYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy년 M월"
        return dateFormatter.string(from: Date())
    }
    
    private func formattedCurrentDay() -> String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: Date())
        return "\(day)일"
    }
}

// Separate section view for clarity
struct SectionView: View {
    let runs: [RunData]
    let title: String
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(title)
                    .bold()
                    .font(.system(size: 16))
                    .foregroundColor(Color("CardFontColor"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if runs.isEmpty {
                VStack{
                    Text("아직 러닝 기록이 없네요.")
//                        .font(.system(size: 14))
                        .foregroundColor(Color("CardFontColor"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("지금이 시작하기에 가장 좋은 시간이에요!🏃🏻‍♀️")
//                        .font(.system(size: 14))
                        .foregroundColor(Color("CardFontColor"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.system(size: 14))
                .padding(10)
                .background(Color("CardColor").opacity(0.3))
                .cornerRadius(10)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                let groupedRuns = groupRunsByMonth(runs: runs)
                ForEach(groupedRuns.sorted { $0.key > $1.key }, id: \.key) { month, runs in
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(runs, id: \.startDate) { run in
                            RunDetailView(run: run)
                        }
                    }
                }
            }
        }
    }
    // 이번 달 러닝 횟수 계산 함수
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
    
    private func groupRunsByMonth(runs: [RunData]) -> [String: [RunData]] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        
        return Dictionary(grouping: runs) { run in
            dateFormatter.string(from: run.startDate)
        }
    }
    
//    private func formatMonth(_ month: String) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM"
//        guard let date = formatter.date(from: month) else { return month }
//        
//        // "yy년 MM월" 형식으로 변환
//        formatter.dateFormat = "yy년 MM월"
//        return formatter.string(from: date)
//    }
//    
//    // 현재 월인지 확인
//    private func checkIfCurrentMonth(month: String) -> Bool {
//        let calendar = Calendar.current
//        let currentYear = calendar.component(.year, from: Date())
//        let currentMonth = calendar.component(.month, from: Date())
//        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM"
//        guard let date = formatter.date(from: month) else { return false }
//        
//        let components = calendar.dateComponents([.year, .month], from: date)
//        return components.year == currentYear && components.month == currentMonth
//    }
}

// View for displaying individual run details
struct RunDetailView: View {
    let run: RunData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text("운동 시간")
                    .font(.caption)
                    .foregroundColor(Color("CardFontColor"))
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
                    .foregroundColor(Color("CardFontColor"))
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
                    .foregroundColor(Color("CardFontColor"))
                    .bold()
                Text("\(run.calories, specifier: "%.1f") kcal")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.pink)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text("페이스")
                    .font(.caption)
                    .foregroundColor(Color("CardFontColor"))
                    .bold()
                Text("\(run.pace / 60, specifier: "%.2f")/km")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.mint)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background(Color("CardColor").opacity(0.3))
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
    RunningDataView(outdoorRuns: [
        RunData(
            duration: 1800, // 30 minutes
            distance: 5000, // 5 km
            calories: 320.5,
            pace: 360, // 6 min/km
            startDate: Date(),
            endDate: Date()
        )
    ], indoorRuns: [
//        RunData(
//            duration: 1500, // 25 minutes
//            distance: 3000, // 3 km
//            calories: 200.0,
//            pace: 300, // 5 min/km
//            startDate: Date(),
//            endDate: Date()
//        )
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
    .background(Color.red.opacity(1))
}
