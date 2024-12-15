//
//  MonthlyInfoView.swift
//  running-check
//
//  Created by mason on 12/12/24.
//

import SwiftUI

struct MonthlyInfoView: View {
    let month: String
    let totalDistance: Double // 총 거리 (km)
    let totalCalories: Double // 총 소모 칼로리 (kcal)
    let totalDuration: TimeInterval // 총 러닝 시간 (초)
    let averagePace: Double // 평균 페이스 ("12'22\"/km")
    let averageCadence: Double // 평균 케이던스 (spm)
    let runCount: Int // 러닝 횟수
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(month) 러닝 기록")
                .font(.headline)
                .padding(.bottom, 10)
            
            HStack {
                Text("총 거리")
                Spacer()
                Text("\(formattedNumber(Int(totalDistance))) km")
                    .bold()
            }
            .padding(.horizontal)
            
            HStack {
                Text("총 칼로리")
                Spacer()
                Text("\(formattedNumber(Int(totalCalories))) kcal")
                    .bold()
            }
            .padding(.horizontal)
            
            HStack {
                Text("총 시간")
                Spacer()
                Text(formatDuration(totalDuration))
                    .bold()
            }
            .padding(.horizontal)
            
            HStack {
                Text("평균 페이스")
                Spacer()
                Text(formatPace(averagePace))
                    .bold()
            }
            .padding(.horizontal)
            
            HStack {
                Text("평균 케이던스")
                Spacer()
                Text("\(formattedNumber(Int(averageCadence))) spm")
                    .bold()
            }
            .padding(.horizontal)
            
            HStack {
                Text("러닝 횟수")
                Spacer()
                Text("\(runCount)회")
                    .bold()
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color("CardColor").opacity(0.3))
        .foregroundColor(Color("CardFontColor"))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
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
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        return "\(hours):\(minutes):\(seconds)"
    }
    
    private func formatPace(_ pace: Double) -> String {
        guard pace > 0 else { return "-" }
        let minutes = Int(pace) / 60
        let seconds = Int(pace) % 60
        return String(format: "%d'%02d\"/km", minutes, seconds)
    }
    private func formattedNumber(_ value: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

//struct HighlightCard: View {
//    let title: String
//    let value: String
//    let systemImage: String
//    
//    var body: some View {
//        VStack(spacing: 10) {
//            Image(systemName: systemImage)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 50, height: 50)
//                .foregroundColor(.white)
//            Text(value)
//                .font(.title2)
//                .bold()
//                .foregroundColor(.white)
//            Text(title)
//                .font(.subheadline)
//                .foregroundColor(.white.opacity(0.8))
//        }
//        .padding()
//        .frame(maxWidth: .infinity, minHeight: 150)
//        .background(LinearGradient(
//            gradient: Gradient(colors: [.blue, .purple]),
//            startPoint: .topLeading,
//            endPoint: .bottomTrailing
//        ))
//        .cornerRadius(15)
//        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
//    }
//}
//
//struct StatCard: View {
//    let title: String
//    let value: String
//    let systemImage: String
//    
//    var body: some View {
//        VStack(spacing: 10) {
//            Image(systemName: systemImage)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 40, height: 40)
//                .foregroundColor(.accentColor)
//            Text(value)
//                .font(.title)
//                .bold()
//            Text(title)
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//        }
//        .padding()
//        .frame(maxWidth: .infinity, minHeight: 120)
//        .background(Color(.secondarySystemBackground))
//        .cornerRadius(12)
//        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
//    }
//}

#Preview {
    MonthlyInfoView(
        month: "24년 12월",
        totalDistance: 223300,
        totalCalories: 4500,
        totalDuration: 3600 * 5 + 30 * 60,
        averagePace: 360,
        averageCadence: 450,
        runCount: 20
    )
}


