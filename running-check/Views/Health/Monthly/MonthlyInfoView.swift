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
    
    let prevTotalDistance: Double // 총 거리 (km)
    let prevTotalCalories: Double // 총 소모 칼로리 (kcal)
    let prevTotalDuration: TimeInterval // 총 러닝 시간 (초)
    let prevAveragePace: Double // 평균 페이스 ("12'22\"/km")
    let prevAverageCadence: Double // 평균 케이던스 (spm)
    let prevRunCount: Int // 러닝 횟수
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ComparisonRow(title: "총 거리", currentValue: totalDistance, prevValue: prevTotalDistance, unit: "KM")
            ComparisonRow(title: "총 칼로리", currentValue: totalCalories, prevValue: prevTotalCalories, unit: "KCAL", isCalories: true)
            ComparisonRow(
                            title: "총 시간",
                            currentValue: totalDuration, // 2시간
                            prevValue: prevTotalDuration, // 1시간 53분 20초
                            unit: "",
                            isDuration: true
                        )
            ComparisonRow(
                            title: "평균 페이스",
                            currentValue: averagePace, // 5분 15초/km
                            prevValue: prevAveragePace, // 5분 35초/km
                            unit: "/KM",
                            isPace: true
                        )
            ComparisonRow(title: "평균 케이던스", currentValue: averageCadence, prevValue: prevAverageCadence, unit: "SPM", isInteger: true)
            ComparisonRow(title: "러닝 횟수", currentValue: Double(runCount), prevValue: Double(prevRunCount), unit: "회", isInteger: true)
        }
        .padding()
        .background(Color("CardColor").opacity(0.5))
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
    private func formattedNumber2(_ value: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

struct ComparisonRow: View {
    let title: String
    let currentValue: Double
    let prevValue: Double
    let unit: String
    var isDuration: Bool = false
    var isPace: Bool = false
    var isInteger: Bool = false // 정수 여부를 나타내는 변수
    var isCalories: Bool = false // 칼로리 여부
    
    var difference: Double {
        currentValue - prevValue
    }
    
    var arrowImage: Image {
            if isPace {
                // 페이스는 낮을수록 좋음
                if difference < 0 {
                    return Image(systemName: "arrowtriangle.down.fill") // 업 화살표
                } else if difference > 0 {
                    return Image(systemName: "arrowtriangle.up.fill") // 다운 화살표
                } else {
                    return Image(systemName: "minus") // 변화 없음
                }
            } else {
                // 일반적인 경우
                if difference > 0 {
                    return Image(systemName: "arrowtriangle.up.fill") // 업 화살표
                } else if difference < 0 {
                    return Image(systemName: "arrowtriangle.down.fill") // 다운 화살표
                } else {
                    return Image(systemName: "minus") // 변화 없음
                }
            }
        }
        
        var arrowColor: Color {
            if isPace {
                // 페이스는 낮을수록 좋음
                if difference < 0 {
                    return .green // 좋아짐 (낮아짐)
                } else if difference > 0 {
                    return .red // 나빠짐 (높아짐)
                } else {
                    return .gray // 변화 없음
                }
            } else {
                // 일반적인 경우
                if difference > 0 {
                    return .green // 상승일 때 초록색
                } else if difference < 0 {
                    return .red // 하락일 때 빨간색
                } else {
                    return .gray // 변화 없음
                }
            }
        }
    
    var body: some View {
        HStack(alignment: .top, spacing: 2) {
            Text(title)
                .frame(alignment: .leading)
            
            Spacer()
            
            VStack {
                // 현재 값
                Text(formattedValue(value: currentValue))
                    .bold()
                
                // 화살표와 변화량
                HStack(spacing: 2) {
                    arrowImage
                        .foregroundColor(arrowColor)
                        .font(.caption)
                    Text(formattedDifference())
                        .foregroundColor(arrowColor)
                        .bold()
                        .font(.caption)
                }
            }
            
            // 단위
            Text(unit)
        }
        .padding(.vertical, 3)
    }
    
    // 값 포맷팅
        private func formattedValue(value: Double) -> String {
            if isCalories {
                return formattedNumber(Int(value)) // 3자리마다 컴마
            } else if isInteger {
                return String(Int(value)) // 정수로 변환
            } else if isDuration {
                return formattedTime(value) // 총 시간 포맷
            } else if isPace {
                return formattedPace(value) // 평균 페이스 포맷
            } else {
                return String(format: "%.2f", value) // 일반 포맷
            }
        }

    // 변화량 포맷팅
        private func formattedDifference() -> String {
            if isCalories {
                return formattedNumber(Int(abs(difference))) // 칼로리 변화량 포맷
            } else if isInteger {
                return String(Int(abs(difference)))
            } else if isDuration {
                return formattedTime(abs(difference)) // 변화량 시간 포맷
            } else if isPace {
                return formattedPace(abs(difference)) // 변화량 페이스 포맷
            } else {
                return String(format: "%.2f", abs(difference))
            }
        }

        // 총 시간 포맷
        private func formattedTime(_ time: TimeInterval) -> String {
            let hours = Int(time) / 3600
            let minutes = (Int(time) % 3600) / 60
            let seconds = Int(time) % 60
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }

        // 평균 페이스 포맷
        private func formattedPace(_ pace: Double) -> String {
            guard pace > 0 else { return "-" }
            let minutes = Int(pace) / 60
            let seconds = Int(pace) % 60
            return String(format: "%d'%02d\"", minutes, seconds)
        }
    
    // 숫자 포맷팅 (3자리마다 컴마)
        private func formattedNumber(_ value: Int) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        }
}

#Preview {
    MonthlyInfoView(
        month: "24년 12월",
        totalDistance: 223.67,
        totalCalories: 4100,
        totalDuration: 3600 * 5 + 30 * 60,
        averagePace: 760,
        averageCadence: 450,
        runCount: 20,
        
        prevTotalDistance: 210.3,
        prevTotalCalories: 4200,
        prevTotalDuration: 3600 * 3 + 30 * 60,
        prevAveragePace: 560,
        prevAverageCadence: 350,
        prevRunCount: 10
    )
}


