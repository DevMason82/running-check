//
//  MonthlyInfoView.swift
//  running-check
//
//  Created by mason on 12/12/24.
//

import SwiftUI

struct MonthlyInfoView: View {
    let totalRunningDistance: Double
    let totalCaloriesBurned: Double
    let totalRunningTime: TimeInterval
    let averagePace: Double
    let averageCadence: Double
    let indoorRunCount: Int
    let outdoorRunCount: Int
    let lastMonthReport: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            HStack {
                Text("거리")
                Spacer()
                Text(String(format: "%.2f km", totalRunningDistance))
                    .bold()
            }
            .padding(.horizontal)
            
            HStack {
                Text("칼로리")
                Spacer()
                Text(String(format: "%.0f kcal", totalCaloriesBurned))
                    .bold()
            }
            .padding(.horizontal)
            
            HStack {
                Text("시간")
                Spacer()
                Text(formattedTime(totalRunningTime))
                    .bold()
            }
            .padding(.horizontal)
            
            HStack {
                Text("평균 페이스")
                Spacer()
//                Text(formattedPace(averagePace))
                Text("\(formatPace(averagePace))/km")
                    .bold()
            }
            .padding(.horizontal)
            
//            HStack {
//                Text("평균 케이던스")
//                Spacer()
//                Text(String(format: "%.0f spm", averageCadence))
//                    .bold()
//            }
//            .padding(.horizontal)
            
            HStack {
                Text("러닝 횟수")
                Spacer()
                Text("\(indoorRunCount + outdoorRunCount)")
                    .bold()
            }
            .padding(.horizontal)
            
            // 보고서 표시
                            VStack(alignment: .leading, spacing: 10) {
                                Text("지난달 달리기 보고서")
                                    .font(.headline)
                                Text(lastMonthReport)
                                    .font(.body)
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                            }
                            .padding(.horizontal)
        }
    }
    private func formattedTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        return "\(hours):\(minutes):\(seconds)"
    }
    
    private func formattedPace(_ pace: Double) -> String {
        guard pace > 0 else { return "-" }
        let minutes = Int(pace) / 60
        let seconds = Int(pace) % 60
        return String(format: "%d:%02d min/km", minutes, seconds)
    }
    
    private func formatPace(_ pace: Double) -> String {
            let minutes = Int(pace) / 60
            let seconds = Int(pace) % 60
            return String(format: "%d'%02d\"", minutes, seconds)
        }
}

struct HighlightCard: View {
    let title: String
    let value: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(LinearGradient(
            gradient: Gradient(colors: [.blue, .purple]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.accentColor)
            Text(value)
                .font(.title)
                .bold()
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}

#Preview {
    MonthlyInfoView(
        totalRunningDistance: 42.195,
        totalCaloriesBurned: 3000,
        totalRunningTime: 3600 * 5 + 30 * 60,
        averagePace: 360,
        averageCadence: 450,
        indoorRunCount: 20,
        outdoorRunCount: 15,
        lastMonthReport: """
                지난달 달리기 요약:
                - 총 거리: 42.20 km
                - 소모 칼로리: 3100 kcal
                - 평균 페이스: 5'30"/km
                - 평균 케이던스: 175.2 spm
                """
    )
}


