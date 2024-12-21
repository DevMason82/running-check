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
            VStack(alignment: .leading, spacing: 20) {
                // 데이터 카드를 반응형으로 배치
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                    StatCardView(
                        title: "총 시간",
                        currentValue: totalDuration,
                        prevValue: prevTotalDuration,
                        unit: "",
                        isDuration: true
                    )
                    StatCardView(
                        title: "총 칼로리",
                        currentValue: totalCalories,
                        prevValue: prevTotalCalories,
                        unit: "KCAL",
                        isCalories: true
                    )
                    StatCardView(
                        title: "총 거리",
                        currentValue: totalDistance,
                        prevValue: prevTotalDistance,
                        unit: "KM"
                    )
                    StatCardView(
                        title: "평균 페이스",
                        currentValue: averagePace,
                        prevValue: prevAveragePace,
                        unit: "/KM",
                        isPace: true
                    )
                    StatCardView(
                        title: "평균 케이던스",
                        currentValue: averageCadence,
                        prevValue: prevAverageCadence,
                        unit: "SPM",
                        isInteger: true
                    )
                    StatCardView(
                        title: "러닝 횟수",
                        currentValue: Double(runCount),
                        prevValue: Double(prevRunCount),
                        unit: "회",
                        isInteger: true
                    )
                }
                .padding(.top, 10)
                
                // 차트 개별 구성
//                VStack(spacing: 15) {
//                    ChartView(
//                        title: "총 시간",
//                        currentValue: totalDuration,
//                        prevValue: prevTotalDuration,
//                        unit: ""
//                    )
//                    ChartView(
//                        title: "총 칼로리",
//                        currentValue: totalCalories,
//                        prevValue: prevTotalCalories,
//                        unit: "KCAL"
//                    )
//                    ChartView(
//                        title: "총 거리",
//                        currentValue: totalDistance,
//                        prevValue: prevTotalDistance,
//                        unit: "KM"
//                    )
//                    ChartView(
//                        title: "평균 페이스",
//                        currentValue: averagePace,
//                        prevValue: prevAveragePace,
//                        unit: "/KM"
//                    )
//                    ChartView(
//                        title: "평균 케이던스",
//                        currentValue: averageCadence,
//                        prevValue: prevAverageCadence,
//                        unit: "SPM"
//                    )
//                    ChartView(
//                        title: "러닝 횟수",
//                        currentValue: Double(runCount),
//                        prevValue: Double(prevRunCount),
//                        unit: "회"
//                    )
//                }
//                .padding(.top, 20)
                
                // 상세 데이터
                //                VStack(spacing: 10) {
                //                    ComparisonRow(title: "총 거리", currentValue: totalDistance, prevValue: prevTotalDistance, unit: "KM")
                //                    ComparisonRow(title: "총 칼로리", currentValue: totalCalories, prevValue: prevTotalCalories, unit: "KCAL", isCalories: true)
                //                    ComparisonRow(
                //                        title: "총 시간",
                //                        currentValue: totalDuration,
                //                        prevValue: prevTotalDuration,
                //                        unit: "",
                //                        isDuration: true
                //                    )
                //                    ComparisonRow(
                //                        title: "평균 페이스",
                //                        currentValue: averagePace,
                //                        prevValue: prevAveragePace,
                //                        unit: "/KM",
                //                        isPace: true
                //                    )
                //                    ComparisonRow(title: "평균 케이던스", currentValue: averageCadence, prevValue: prevAverageCadence, unit: "SPM", isInteger: true)
                //                    ComparisonRow(title: "러닝 횟수", currentValue: Double(runCount), prevValue: Double(prevRunCount), unit: "회", isInteger: true)
                //                }
                //                .padding(.top, 20)
            }
            //            .padding()
            //            .background(Color("CardColor").opacity(0.1))
            //            .cornerRadius(10)
            .padding()
        }
        //        .background(Color("BackgroundColor"))
    }
}

// MARK: - BarChart View
struct BarChart: View {
    let data: [(String, Double, Double, String)]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("월별 데이터 비교")
                .font(.headline)
                .padding(.bottom, 5)
            
            Chart {
                ForEach(data.indices, id: \.self) { index in
                    let item = data[index]
                    BarMark(
                        x: .value("Category", item.0),
                        y: .value("Current", item.1)
                    )
                    .foregroundStyle(Color.blue)
                    
                    BarMark(
                        x: .value("Category", item.0),
                        y: .value("Previous", item.2)
                    )
                    .foregroundStyle(Color.gray.opacity(0.7))
                }
            }
            .chartYAxisLabel("Values")
            .chartXAxisLabel("Metrics")
            .frame(height: 300)
        }
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

// MARK: - ChartView Component
import SwiftUI
import Charts

struct ChartView: View {
    let title: String
    let currentValue: Double  // 총 시간, 평균 페이스 포함
    let prevValue: Double
    let unit: String
    
    // 애니메이션 상태 변수 (막대 크기)
    @State private var animatedCurrentValue: Double = 0
    @State private var animatedPrevValue: Double = 0
    
    // 값 차이 계산
    var difference: Double {
        currentValue - prevValue
    }
    
    // 동적 색상 설정
    var barColor: Color {
        if title == "평균 페이스" {
            return difference < 0 ? .green : (difference > 0 ? .red : .gray)
        } else {
            return difference > 0 ? .green : (difference < 0 ? .red : .gray)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .bold()
                .foregroundStyle(Color(.darkGray))
            
            Chart {
                // 이번 달 데이터 (애니메이션 적용)
                BarMark(
                    x: .value("Category", "이번 달"),
                    y: .value("Value", animatedCurrentValue)  // 애니메이션된 값 사용
                )
                .foregroundStyle(barColor)
                .annotation(position: .top) {
                    Text(formattedValue(animatedCurrentValue))
                        .font(.caption)
                        .foregroundColor(barColor)
                        .bold()
                }
                
                // 전 달 데이터 (애니메이션 적용)
                BarMark(
                    x: .value("Category", "전 달"),
                    y: .value("Value", animatedPrevValue)  // 애니메이션된 값 사용
                )
                .foregroundStyle(.gray)
                .annotation(position: .top) {
                    Text(formattedValue(animatedPrevValue))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .chartYAxis {
                AxisMarks(preset: .automatic, position: .leading) { mark in
                    AxisGridLine()
                        .foregroundStyle(Color.gray.opacity(0.3))
                    AxisValueLabel()
                        .foregroundStyle(Color(.darkGray))
                    AxisTick()
                        .foregroundStyle(Color(.darkGray))
                }
            }
            .chartXAxis {
                AxisMarks(preset: .automatic, position: .bottom) { mark in
                    AxisValueLabel()
                        .foregroundStyle(Color(.darkGray))
                    AxisTick()
                        .foregroundStyle(Color(.darkGray))
                }
            }
            .chartYAxisLabel(unit)
            .frame(height: 200)
            .onAppear {
                // 막대 애니메이션 적용
                withAnimation(.easeOut(duration: 1.0)) {
                    animatedCurrentValue = currentValue
                    animatedPrevValue = prevValue
                }
            }
        }
        .padding(.bottom, 15)
    }
    
    // 값 포맷팅 (시간, 페이스, 일반 값)
    private func formattedValue(_ value: Double) -> String {
        if title == "총 시간" {
            return formattedTime(value)
        } else if title == "평균 페이스" {
            return formattedPace(value)
        } else {
            return String(format: "%.0f", value)
        }
    }
    
    // 총 시간 포맷 메서드 (시간:분:초)
    private func formattedTime(_ time: Double) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // 평균 페이스 포맷 메서드 (분:초)
    private func formattedPace(_ pace: Double) -> String {
        guard pace > 0 else { return "-" }
        let minutes = Int(pace) / 60
        let seconds = Int(pace) % 60
        return String(format: "%d'%02d\"", minutes, seconds)
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
                    .font(.caption)
                Text(formattedDifference())
                    .foregroundColor(arrowColor)
                    .font(.caption)
            }
            Text(unit)
                .font(.subheadline)
        }
        .padding()
        .frame(minWidth: 150, maxWidth: .infinity)
        .background(Color("CardColor").opacity(0.5))
        .foregroundColor(Color("CardFontColor"))
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
