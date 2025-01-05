//
//  MonthlyRunningDataView.swift
//  running-check
//
//  Created by mason on 12/12/24.
//

import SwiftUI
import Photos

struct MonthlyRunningSummary {
    let month: String
    let totalDistance: Double
    let totalCalories: Double
    let totalDuration: TimeInterval
    let averagePace: Double
    let averageCadence: Double
    let runCount: Int
    
    let prevTotalDistance: Double
    let prevTotalCalories: Double
    let prevTotalDuration: TimeInterval
    let prevAveragePace: Double
    let prevAverageCadence: Double
    let prevRunCount: Int
}

struct MonthlyRunningDataView: View {
    @Environment(\.presentationMode) var presentationMode // 뒤로가기 기능을 제공
    @StateObject private var weatherKitViewModel = WeatherKitViewModel()
    @StateObject private var healthViewModel = HealthKitViewModel()
    @StateObject private var currentMonthRunningReportViewModel = CurrentMonthRunningReportViewModel()
    @StateObject private var prevRunningReportViewModel = PrevRunningReportViewModel()
    @State private var isLoading = true // 로딩 상태를 관리
    @State private var capturedImage: UIImage? = nil
    
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
                    Color("BackgroundColor")
                        .ignoresSafeArea()
                    
                    
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
                                    runCount: currentMonthRunningReportViewModel.runCount,
                                    
                                    prevTotalDistance: prevRunningReportViewModel.totalDistance,
                                    prevTotalCalories: prevRunningReportViewModel.totalCalories,
                                    prevTotalDuration: prevRunningReportViewModel.totalDuration,
                                    prevAveragePace: prevRunningReportViewModel.averagePace,
                                    prevAverageCadence: prevRunningReportViewModel.averageCadence,
                                    prevRunCount: prevRunningReportViewModel.runCount
                                )
                                
                            } else {
                                NoDataView()
                            }
                        }
                    }
                    .onAppear() {
                        captureAndSave()
                    }
                    .navigationTitle("\(healthViewModel.currentMonth) 러닝 기록")
                    .navigationBarTitleDisplayMode(.large)
                    .frame(maxWidth: .infinity)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if let capturedImage = capturedImage {
                                ShareLink(item: Image(uiImage: capturedImage),
                                          preview: SharePreview("러닝 기록", image: Image(uiImage: capturedImage))) {
                                    Image(systemName: "square.and.arrow.up")
                                        .imageScale(.large)
                                }
                            }
                        }
                    }
                    
                }
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
    
    private func convertViewToImage() -> UIImage {
        let summary = MonthlyRunningSummary(
            month: healthViewModel.currentMonth,
            totalDistance: currentMonthRunningReportViewModel.totalDistance,
            totalCalories: currentMonthRunningReportViewModel.totalCalories,
            totalDuration: currentMonthRunningReportViewModel.totalDuration,
            averagePace: currentMonthRunningReportViewModel.averagePace,
            averageCadence: currentMonthRunningReportViewModel.averageCadence,
            runCount: currentMonthRunningReportViewModel.runCount,
            
            prevTotalDistance: prevRunningReportViewModel.totalDistance,
            prevTotalCalories: prevRunningReportViewModel.totalCalories,
            prevTotalDuration: prevRunningReportViewModel.totalDuration,
            prevAveragePace: prevRunningReportViewModel.averagePace,
            prevAverageCadence: prevRunningReportViewModel.averageCadence,
            prevRunCount: prevRunningReportViewModel.runCount
        )
        
        let customView = MonthlyCustomRunningDetailView(summary: summary)
        let controller = UIHostingController(rootView: customView)
        let view = controller.view
        
        let targetSize = CGSize(width: 300, height: 600)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { context in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }
    
    private func captureAndSave() {
        let image = convertViewToImage()
        capturedImage = image
        
        // 앨범 저장 부분 제거
        print("이미지가 캡처되었습니다.")
    }
}

// 커스텀 러닝 기록 뷰
struct MonthlyCustomRunningDetailView: View {
    let summary: MonthlyRunningSummary
    
    var body: some View {
        VStack(spacing: 15) {
            //                    HStack {
            //                        Text("러닝체크 - \(summary.month)")
            //                            .font(.title3)
            //                            .bold()
            //                        Spacer()
            //                    }
            //                    .padding(.bottom, 15)
            MonthlyInfoViewSaveImage(
                month:summary.month,
                totalDistance: summary.totalDistance,
                totalCalories: summary.totalCalories,
                totalDuration: summary.totalDuration,
                averagePace: summary.averagePace,
                averageCadence: summary.averageCadence,
                runCount: summary.runCount,
                
                prevTotalDistance: summary.prevTotalDistance,
                prevTotalCalories: summary.prevTotalCalories,
                prevTotalDuration: summary.prevTotalDuration,
                prevAveragePace: summary.prevAveragePace,
                prevAverageCadence: summary.prevAverageCadence,
                prevRunCount: summary.prevRunCount
            )
            
        }
        .padding()
        .background(Color("BackgroundColor").opacity(0.1))
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
    //        formatter.locale = Locale(identifier: "ko_KR")  // 한국어 날짜 포맷
    //        return formatter.string(from: date)
    //    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd - HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    private func formattedPace(_ pace: Double) -> String {
        guard pace > 0 else { return "-" }
        let minutes = Int(pace) / 60
        let seconds = Int(pace) % 60
        return String(format: "%d'%02d\"", minutes, seconds)
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
        VStack {
            Text("이번 달 러닝 기록이 없습니다.")
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
        .background(Color("BackgroundColor").opacity(0.1))
    }
}

#Preview {
    MonthlyRunningDataView()
        .background(Color("BackgroundColor"))
    
}
