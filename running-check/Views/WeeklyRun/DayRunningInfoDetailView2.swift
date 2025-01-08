//
//  DayRunningInfoDetailView2.swift
//  running-check
//
//  Created by mason on 1/2/25.
//

import SwiftUI

struct DayRunningInfoDetailView2: View {
    let distance: Double
    let duration: TimeInterval
    let calories: Double
    let heartRate: Double
    let pace: Double
    let cadence: Double
    
    var body: some View {
        VStack {
            DayKMTotalView2(distance: distance)
            
            LazyVGrid(columns: [GridItem(.fixed(130)), GridItem(.fixed(130))], spacing: 10) {
                gridItem(title: "🏃🏻‍♂️평균 페이스", value: formattedPace(pace))
                gridItem(title: "⏱️ 시간", value: formatTime(duration))
                gridItem(title: "🔥 칼로리", value: formatWithCommas(calories))
                gridItem(title: "❤️ 평균 심박수", value: "\(String(format: "%.0f", heartRate))")
                gridItem(title: "👟 평균 케이던스", value: "\(String(format: "%.0f", cadence))")
            }
        }
//        GeometryReader { geometry in
//            let columnCount = max(2, Int(geometry.size.width / 160))  // 최소 2열 보장
//            let columns: [GridItem] = Array(repeating: GridItem(.fixed(160)), count: columnCount)
//            
//            VStack(spacing: 15) {
//                DayKMTotalView2(distance: distance)
//                
//                LazyVGrid(columns: columns) {
//                    gridItem(title: "🏃🏻‍♂️평균 페이스", value: formattedPace(pace))
//                    gridItem(title: "⏱️ 시간", value: formatTime(duration))
//                    gridItem(title: "🔥 칼로리", value: formatWithCommas(calories))
//                    gridItem(title: "❤️ 평균 심박수", value: "\(String(format: "%.0f", heartRate))")
//                    gridItem(title: "👟 평균 케이던스", value: "\(String(format: "%.0f", cadence))")
//                }
//            }
//        }
    }
    
    // 각 그리드 아이템 뷰
    @ViewBuilder
    private func gridItem(title: String, value: String) -> some View {
        VStack {
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title3)
                .bold()
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.caption2)
                .bold()
        }
        .padding()
        .background(Color("CardColor").opacity(0.1))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .cornerRadius(10)
    }
    
    // 시간 포맷 (초 → 시:분:초)
    private func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    // 날짜 포맷 (Date → String)
//    private func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.locale = Locale(identifier: "ko_KR")
//        return formatter.string(from: date)
//    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd"  // 'yy.mm.dd' 형식으로 변경
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    private func formattedPace(_ pace: Double) -> String {
        guard pace > 0 else { return "-" }
        let minutes = Int(pace) / 60
        let seconds = Int(pace) % 60
        return String(format: "%d'%02d\"", minutes, seconds)
    }
    
    // 3자리마다 콤마를 찍는 포맷터
    private func formatWithCommas(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

#Preview {
    DayRunningInfoDetailView2(
        distance: 7560,  // 7.5 km
        duration: 3600,  // 1시간
        calories: 23600,
        heartRate: 145,
        pace: 398.0845880288003,
        cadence: 177
    )
}
