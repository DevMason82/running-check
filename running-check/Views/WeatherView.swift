//
//  WeatherView.swift
//  running-check
//
//  Created by mason on 11/18/24.

import SwiftUI

struct WeatherView: View {
    @EnvironmentObject private var weatherKitViewModel: WeatherKitViewModel
    @EnvironmentObject private var locationManagerNew: LocationManagerNew
    @EnvironmentObject private var healthViewModel: HealthKitViewModel
    @EnvironmentObject private var weeklyRunningDataViewModel: WeeklyRunningDataViewModel
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var lastRefreshTime: Date = .distantPast // 마지막 데이터 로드 시간
    @State private var isLoading: Bool = false
    @State private var lastScenePhaseRefresh: Date = .distantPast
    
    var body: some View {
        ZStack {
            if let runningGrade = weatherKitViewModel.runningGrade {
                GradientBackground(runningGrade: runningGrade)
            } else {
                GradientBackgroundPlaceholder()
            }
            
            if let errorMessage = weatherKitViewModel.errorMessage {
                ErrorView(
                    errorMessage: errorMessage,
                    onSettingsTap: openAppSettings
                )
            } else if weatherKitViewModel.weatherData != nil {
//                weatherContent(weather: weather)
                ScrollView(showsIndicators: false) {
                    contentView
                }
                .refreshable {
                    await refreshData()
                }
            } else {
                LoadingView(message: "러닝체크 로딩중...🏃🏻‍♂️")
            }
            
//            ScrollView(showsIndicators: false) {
//                contentView
//            }
//            .refreshable {
//                await refreshData()
//            }
        }
        .onAppear {
            Task {
                await refreshData()
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                Task {
                    await refreshData()
//                    await throttledRefresh()
                }
            }
        }
    }
    
    private var contentView: some View {
        Group {
            if let errorMessage = weatherKitViewModel.errorMessage {
                ErrorView(
                    errorMessage: errorMessage,
                    onSettingsTap: openAppSettings
                )
            } else if let weather = weatherKitViewModel.weatherData {
                weatherContent(weather: weather)
            } else {
                LoadingView(message: "러닝체크 로딩중...🏃🏻‍♂️")
            }
        }
    }
    
    private func weatherContent(weather: WeatherData) -> some View {
        VStack {
            WeatherHeaderView(
                weather: weather,
                locationName: locationManagerNew.locality ?? "Loading...",
                thoroughfare: locationManagerNew.thoroughfare ?? "Loading..."
            )
            .padding(.bottom, 20)
            
            if let grade = weatherKitViewModel.runningGrade {
                RunningGradeView(grade: grade)
            } else {
                Text("Running grade is being evaluated...")
                    .foregroundColor(.secondary)
                    .padding(.bottom, 5)
            }
            
            //RunningCoachView(coach: weatherKitViewModel.runningCoach)
            
            
            VStack {
                Text(weatherKitViewModel.runningCoach?.simpleFeedback ?? "러닝 준비 완료!")
                    .font(.body)
                    .foregroundStyle(Color("CardFontColor"))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineSpacing(5)
            }
            .padding()
            .background(Color("CardColor").opacity(0.3))
            .cornerRadius(10)
            .padding(.horizontal)
            
            VStack {
                NavigationLink(destination: AICoachView()) {
                    HStack(spacing: 5) {
                        Image(systemName: "sparkles")
                            .resizable() // 이미지 크기를 조절할 수 있도록 설정
                            .scaledToFit() // 이미지의 비율을 유지하며 크기 조절
                            .foregroundColor(Color("CardFontColor"))
                            .frame(width: 14) // 원하는 크기 지정
                        Text("AI 러닝코칭")
                            .font(.headline)
                            .foregroundColor(Color("CardFontColor"))
                        Image(systemName: "arrow.forward")
                            .font(.title3)
                            .foregroundColor(Color("CardFontColor"))
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                    .padding(.bottom, 15)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
//            VStack {
//                NavigationLink(value: weatherKitViewModel.runningCoach) {
//                    HStack {
//                        Text("더보기")
//                            .font(.headline)
//                            .foregroundColor(Color("CardFontColor"))
//                        Image(systemName: "arrow.forward")
//                            .font(.title3)
//                            .foregroundColor(Color("CardFontColor"))
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 5)
//                    .padding(.bottom, 15)
//                }
//                .frame(maxWidth: .infinity, alignment: .trailing)
//            }
//            .navigationDestination(for: RunningCoach.self) { coach in
//                RunningCoachView(coach: coach, grade: weatherKitViewModel.runningGrade)
//            }
            
            Divider()
                .frame(height: 1)
                .background(Color("CardFontColor").opacity(0.35))
                .padding(.horizontal)
                .padding(.bottom, 15)
            
            WeeklyRunningChckView(weeklyRunningStatus: weeklyRunningDataViewModel.weeklyRunningStatus)
               
            Divider()
                .frame(height: 1)
                .background(Color("CardFontColor").opacity(0.35))
                .padding(.horizontal)
                .padding(.vertical, 15)
            
            WeatherGridView(weather: weather)
        }
    }
    
    private func refreshData() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
//        lastRefreshTime = Date()
        await weatherKitViewModel.fetchWeatherAndEvaluateRunning()
        await healthViewModel.fetchAllHealthDataToday()
        await weeklyRunningDataViewModel.fetchWeeklyRunningData()
    }
    
//    private func throttledRefresh() async {
//        let now = Date()
//        if now.timeIntervalSince(lastScenePhaseRefresh) > 180 {
//            await refreshDataIfNeeded()
//            lastScenePhaseRefresh = now
//        }
//    }
//    
//    private func refreshDataIfNeeded() async {
//        if Date().timeIntervalSince(lastRefreshTime) > 180 { // 최소 3분 간격으로 갱신
//            await refreshData()
//        }
//    }
//    
//    private func shouldRefresh() -> Bool {
//        return Date().timeIntervalSince(lastRefreshTime) > 180 // 최소 3분 간격 확인
//    }
    
    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            print("Unable to open app settings.")
            return
        }
        UIApplication.shared.open(url)
    }
}

struct GradientBackgroundPlaceholder: View {
    var body: some View {
        Color("BackgroundColor")
            .ignoresSafeArea()
    }
}

#Preview {
    WeatherView()
        .environmentObject(WeatherKitViewModel())
        .environmentObject(LocationManagerNew())
        .environmentObject(HealthKitViewModel())
        .environmentObject(WeeklyRunningDataViewModel())
}

#Preview {
    WeatherView()
        .environment(\.colorScheme, .dark)
        .environmentObject(WeatherKitViewModel())
        .environmentObject(LocationManagerNew())
        .environmentObject(HealthKitViewModel())
        .environmentObject(WeeklyRunningDataViewModel())
}
