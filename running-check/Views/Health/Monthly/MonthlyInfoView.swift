//
//  MonthlyInfoView.swift
//  running-check
//
//  Created by mason on 12/12/24.
//

import SwiftUI
import Charts

struct MonthlyInfoView: View {
    let month: String
    let totalDistance: Double // 총 거리 (km)
    let totalCalories: Double // 총 소모 칼로리 (kcal)
    let totalDuration: TimeInterval // 총 러닝 시간 (초)
    let averagePace: Double // 평균 페이스 ("12'22\"/km")
    let averageCadence: Double // 평균 케이던스 (spm)
    let runCount: Int // 러닝 횟수
    
    let prevTotalDistance: Double // 이전 총 거리
    let prevTotalCalories: Double // 이전 총 칼로리
    let prevTotalDuration: TimeInterval // 이전 러닝 시간
    let prevAveragePace: Double // 이전 평균 페이스
    let prevAverageCadence: Double // 이전 평균 케이던스
    let prevRunCount: Int // 이전 러닝 횟수
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        ScrollView {
            KMTotalView(totalDistance: totalDistance, prevTotalDistance: prevTotalDistance)
            
            VStack() {
                Text("*비교값: 지난달")
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                // 데이터 카드를 반응형으로 배치
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                    StatCardView(
                        title: "평균 페이스",
                        currentValue: averagePace,
                        prevValue: prevAveragePace,
                        unit: "",
                        isPace: true
                    )
                    StatCardView(
                        title: "총 칼로리",
                        currentValue: totalCalories,
                        prevValue: prevTotalCalories,
                        unit: "",
                        isCalories: true
                    )
                    StatCardView(
                        title: "평균 케이던스",
                        currentValue: averageCadence,
                        prevValue: prevAverageCadence,
                        unit: "",
                        isInteger: true
                    )
                    
                    StatCardView(
                        title: "총 시간",
                        currentValue: totalDuration,
                        prevValue: prevTotalDuration,
                        unit: "",
                        isDuration: true
                    )
                    StatCardView(
                        title: "러닝 횟수",
                        currentValue: Double(runCount),
                        prevValue: Double(prevRunCount),
                        unit: "",
                        isInteger: true
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - StatCardView
struct StatCardView: View {
    let title: String
    let currentValue: Double
    let prevValue: Double
    let unit: String
    var isDuration: Bool = false
    var isPace: Bool = false
    var isInteger: Bool = false
    var isCalories: Bool = false // 칼로리 여부
    
    var difference: Double {
        currentValue - prevValue
    }
    
    var arrowImage: Image {
        if isPace {
            // 페이스는 낮을수록 좋음
            if difference < 0 {
                return Image(systemName: "arrowtriangle.down.fill") // 좋아짐
            } else if difference > 0 {
                return Image(systemName: "arrowtriangle.up.fill") // 나빠짐
            } else {
                return Image(systemName: "minus") // 변화 없음
            }
        } else {
            // 일반적인 경우
            if difference > 0 {
                return Image(systemName: "arrowtriangle.up.fill") // 증가
            } else if difference < 0 {
                return Image(systemName: "arrowtriangle.down.fill") // 감소
            } else {
                return Image(systemName: "minus") // 변화 없음
            }
        }
    }
    
    var arrowColor: Color {
        if isPace {
            // 페이스는 낮을수록 좋음
            return difference < 0 ? .green : .red
        } else {
            return difference > 0 ? .green : .red
        }
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.headline)
            
            // 현재 값 표시
            Text(formattedValue(value: currentValue))
                .font(.title2)
                .bold()
            
            // 변화량 및 화살표
            HStack(spacing: 5) {
                arrowImage
                    .foregroundColor(arrowColor)
                    .bold()
                //                    .font(.caption)
                Text(formattedDifference())
                    .foregroundColor(arrowColor)
                    .bold()
                //                    .font(.caption)
            }
            //            Text(unit)
            //                .font(.subheadline)
        }
        .padding()
        .frame(minWidth: 150, maxWidth: .infinity)
        .background(Color("CardColor").opacity(0.1))
        //        .foregroundColor(Color("CardFontColor"))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // 값 포맷팅
    private func formattedValue(value: Double) -> String {
        if isCalories || isInteger {
            return formattedNumber(Int(value)) // 3자리마다 콤마 추가
        } else if title == "총 거리" {
            return formattedDecimal(value) // 소수점 유지, 3자리마다 콤마
        } else if isDuration {
            return formattedTime(value) // 시간 포맷
        } else if isPace {
            return formattedPace(value) // 페이스 포맷
        } else {
            return String(format: "%.2f", value)
        }
    }
    
    // 변화량 포맷팅
    private func formattedDifference() -> String {
        if isCalories || isInteger {
            return formattedNumber(Int(abs(difference))) // 3자리마다 콤마 추가
        } else if title == "총 거리" {
            return formattedDecimal(abs(difference)) // 소수점 유지, 3자리마다 콤마
        } else if isDuration {
            return formattedTime(abs(difference)) // 시간 포맷
        } else if isPace {
            return formattedPace(abs(difference)) // 페이스 포맷
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
    
    // 3자리마다 콤마 추가 (정수)
    private func formattedNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    // 소수점 유지, 3자리마다 콤마 추가
    private func formattedDecimal(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
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
    .background(Color("BackgroundColor"))
    .environment(\.colorScheme, .light)
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
    .background(Color("BackgroundColor"))
    .environment(\.colorScheme, .dark)
}
