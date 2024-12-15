//
//  MonthlyRunningDataView.swift
//  running-check
//
//  Created by mason on 12/12/24.
//

import SwiftUI

struct MonthlyRunningDataView: View {
    @StateObject private var weatherKitViewModel = WeatherKitViewModel()
    @StateObject private var healthViewModel = HealthKitViewModel()
    @StateObject private var currentMonthRunningReportViewModel = CurrentMonthRunningReportViewModel()
    @StateObject private var prevRunningReportViewModel = PrevRunningReportViewModel()
    @State private var isLoading = true // 로딩 상태를 관리
    
    var body: some View {
        ZStack {
            if isLoading {
                // 로딩 UI
                LoadingView(message: "러닝체크 로딩중...🏃🏻‍♂️")
                    .transition(.opacity) // 부드러운 전환 효과 추가
                    .onAppear {
                        Task {
                            fetchData()
                        }
                    }
            } else {
                ZStack {
                    if let runningGrade = weatherKitViewModel.runningGrade {
                        GradientBackground(runningGrade: runningGrade)
                    } else {
                        GradientBackgroundPlaceholder()
                    }
                    
                    ScrollView(showsIndicators: false) {
                        VStack {
                            if healthViewModel.totalRunningDistance > 0 {
                                MonthlyInfoView(
                                    month:healthViewModel.currentMonth,
                                    totalDistance: currentMonthRunningReportViewModel.totalDistance,
                                    totalCalories: currentMonthRunningReportViewModel.totalCalories,
                                    totalDuration: currentMonthRunningReportViewModel.totalDuration,
                                    averagePace: currentMonthRunningReportViewModel.averagePace,
                                    averageCadence: currentMonthRunningReportViewModel.averageCadence,
                                    runCount: currentMonthRunningReportViewModel.runCount
                                )
                                PrevMonthlyInfoView(
                                    totalDistance: prevRunningReportViewModel.totalDistance,
                                    totalCalories: prevRunningReportViewModel.totalCalories,
                                    totalDuration: prevRunningReportViewModel.totalDuration,
                                    averagePace: prevRunningReportViewModel.averagePace,
                                    averageCadence: prevRunningReportViewModel.averageCadence,
                                    runCount: prevRunningReportViewModel.runCount
                                )
                            } else {
                                NoDataView()
                            }
                        }
                        .padding()
                    }
                    .navigationTitle("\(healthViewModel.currentMonth) 러닝 기록")
                    .navigationBarTitleDisplayMode(.large)
                }
                
//                .onAppear {
//                    fetchData()
//                }
            }
        }
        .animation(.easeInOut, value: isLoading) // 상태 변경 시 애니메이션
        
    }
    
    private func fetchData() {
        Task {
            isLoading = true
            await weatherKitViewModel.fetchWeatherAndEvaluateRunning()
            await healthViewModel.fetchMonthlyData()
            await currentMonthRunningReportViewModel.fetchCurrentMonthReport()
            await prevRunningReportViewModel.fetchLastMonthReport()
            isLoading = false
        }
    }
}

// 헤더 뷰
struct HeaderView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title)
            .bold()
            .padding(.bottom, 20)
    }
}

// 데이터가 없을 때의 뷰
struct NoDataView: View {
    var body: some View {
        ZStack {
//            Color(.systemBackground)
//                .ignoresSafeArea()
            
            VStack {
                Text("이번 달 데이터가 없습니다.")
                    .foregroundColor(Color("CardFontColor"))
                    .font(.headline)
                    .padding()
            }
            .background(Color.clear)
        }
    }
}

#Preview {
    MonthlyRunningDataView()
    
}
