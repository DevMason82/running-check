//
//  WeatherView.swift
//  running-check
//
//  Created by mason on 11/18/24.
//
//import SwiftUI
//
//struct WeatherView: View {
//    @EnvironmentObject private var weatherKitViewModel: WeatherKitViewModel
//    @EnvironmentObject private var locationManagerNew: LocationManagerNew
//    @EnvironmentObject private var healthViewModel: HealthKitViewModel
//    @Environment(\.scenePhase) private var scenePhase // 앱의 생명주기 감지
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                if let runningGrade = weatherKitViewModel.runningGrade {
//                    GradientBackground(runningGrade: runningGrade)
//                } else {
//                    GradientBackgroundPlaceholder() // nil 상태에 대한 대체 UI
//                }
//                
//                ScrollView(showsIndicators: false) {
//                    if let errorMessage = weatherKitViewModel.errorMessage {
//                        ErrorView(
//                            errorMessage: errorMessage,
//                            onSettingsTap: openAppSettings
//                        )
//                    } else if let weather = weatherKitViewModel.weatherData {
//                        VStack {
//                            WeatherHeaderView(
//                                weather: weather,
//                                locationName: locationManagerNew.locality ?? "Loading...",
//                                thoroughfare: locationManagerNew.thoroughfare ?? "Loading..."
//                            )
//                        }
//                        .padding(.bottom, 20)
//                        
//                        if let grade = weatherKitViewModel.runningGrade {
//                            RunningGradeView(grade: grade)
//                        } else {
//                            Text("Running grade is being evaluated...")
//                                .foregroundColor(.secondary)
//                                .padding(.bottom, 15)
//                        }
//                        
//                        VStack {
//                            RunningCoachView(
//                                coach: weatherKitViewModel.runningCoach
//                            )
//                        }
//                        .padding(.bottom, 15)
//                        
//                        VStack {
//                            Divider()
//                                .bold()
//                                .overlay(Color("CardFontColor"))
//                        }
//                        .padding(.horizontal)
//                        .padding(.bottom, 15)
//                        
//                        VStack {
//                            RunningDataView(
//                                outdoorRuns: healthViewModel.outdoorRuns,
//                                indoorRuns: healthViewModel.indoorRuns,
//                                indoorRunCount: healthViewModel.allIndoorRunsThisMonth,
//                                outdoorRunCount: healthViewModel.allOutdoorRunsThisMonth
//                            )
//                        }
//                        .padding(.bottom, 15)
//                        
//                        VStack {
//                            Divider()
//                                .bold()
//                                .overlay(Color("CardFontColor"))
//                        }
//                        .padding(.horizontal)
//                        .padding(.bottom, 15)
//                        
//                        WeatherGridView(weather: weather)
//                    } else {
//                        LoadingView(message: "Loading...")
//                    }
//                }
//                .refreshable {
//                    print("Refreshing data...")
//                    await refreshData()
//                }
//                
//                
//            }
//        }
//        .onAppear {
//            print("WeatherView appeared")
//        }
//        .onChange(of: scenePhase) {
//            if scenePhase == .active {
//                Task {
//                    await refreshData()
//                }
//            }
//        }
//    }
//    
//    private func refreshData() async {
//        await weatherKitViewModel.fetchWeatherAndEvaluateRunning()
//        await healthViewModel.fetchAllHealthDataToday()
//    }
//    
//    private func openAppSettings() {
//        if let url = URL(string: UIApplication.openSettingsURLString) {
//            UIApplication.shared.open(url)
//        }
//    }
//}
//
//struct GradientBackgroundPlaceholder: View {
//    var body: some View {
//        Color("BackgroundColor")
//            .ignoresSafeArea()
//    }
//}

import SwiftUI

struct WeatherView: View {
    @EnvironmentObject private var weatherKitViewModel: WeatherKitViewModel
    @EnvironmentObject private var locationManagerNew: LocationManagerNew
    @EnvironmentObject private var healthViewModel: HealthKitViewModel
    @Environment(\.scenePhase) private var scenePhase

    @State private var lastRefreshTime: Date = .distantPast // 마지막 데이터 로드 시간

    var body: some View {
        NavigationStack {
            ZStack {
                if let runningGrade = weatherKitViewModel.runningGrade {
                    GradientBackground(runningGrade: runningGrade)
                } else {
                    GradientBackgroundPlaceholder()
                }
                
                ScrollView(showsIndicators: false) {
                    contentView
                }
                .refreshable {
                    await refreshData()
                }
            }
        }
        .onAppear {
            Task {
                await refreshData()
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                Task {
                    await refreshDataIfNeeded()
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
                LoadingView(message: "Loading...")
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
                    .padding(.bottom, 15)
            }
            
            RunningCoachView(coach: weatherKitViewModel.runningCoach)
                .padding(.bottom, 15)
            
            Divider().padding(.horizontal).padding(.bottom, 15)
            
            RunningDataView(
                outdoorRuns: healthViewModel.outdoorRuns,
                indoorRuns: healthViewModel.indoorRuns,
                indoorRunCount: healthViewModel.allIndoorRunsThisMonth,
                outdoorRunCount: healthViewModel.allOutdoorRunsThisMonth
            )
            .padding(.bottom, 15)
            
            Divider().padding(.horizontal).padding(.bottom, 15)
            
            WeatherGridView(weather: weather)
        }
    }

    private func refreshData() async {
        if shouldRefresh() {
            lastRefreshTime = Date()
            await weatherKitViewModel.fetchWeatherAndEvaluateRunning()
            await healthViewModel.fetchAllHealthDataToday()
        }
    }

    private func refreshDataIfNeeded() async {
        if Date().timeIntervalSince(lastRefreshTime) > 300 { // 최소 5분 간격으로 갱신
            await refreshData()
        }
    }

    private func shouldRefresh() -> Bool {
        return Date().timeIntervalSince(lastRefreshTime) > 300 // 최소 5분 간격 확인
    }

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
}

#Preview {
    WeatherView()
        .environment(\.colorScheme, .dark)
        .environmentObject(WeatherKitViewModel())
        .environmentObject(LocationManagerNew())
        .environmentObject(HealthKitViewModel())
}
