//
//  PrevMonthlyInfoView.swift
//  running-check
//
//  Created by mason on 12/13/24.
//

import SwiftUI

struct PrevMonthlyInfoView: View {
    let totalDistance: Double // 총 거리 (km)
    let totalCalories: Double // 총 소모 칼로리 (kcal)
    let totalDuration: TimeInterval // 총 러닝 시간 (초)
    let averagePace: Double // 평균 페이스
    let averageCadence: Double // 평균 케이던스 (spm)
    let runCount: Int // 러닝 횟수
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("지난달 러닝 기록")
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
        .foregroundColor(Color("CardFontColor"))
//        .background(Color(.secondarySystemBackground))
//        .cornerRadius(10)
//        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
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

#Preview {
    PrevMonthlyInfoView(
        totalDistance: 223300,
        totalCalories: 4500,
        totalDuration: 3600 * 5 + 30 * 60,
        averagePace: 360,
        averageCadence: 450,
        runCount: 20
    )
}
