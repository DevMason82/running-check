//
//  WeatherView.swift
//  running-check
//
//  Created by mason on 11/18/24.
//

import SwiftUI
import CoreLocation

struct WeatherView: View {
    @StateObject private var weatherKitViewModel = WeatherKitViewModel()
    @StateObject private var locationManagerNew = LocationManagerNew()
    @StateObject private var healthViewModel = HealthKitViewModel()
    @Environment(\.scenePhase) private var scenePhase // 앱의 생명주기 감지
    
    var body: some View {
        ZStack {
            GradientBackground(runningGrade: weatherKitViewModel.runningGrade ?? .good)
                        
            ScrollView(showsIndicators: false) {
                if let errorMessage = weatherKitViewModel.errorMessage {
                    ErrorView(
                        errorMessage: errorMessage,
                        onSettingsTap: openAppSettings
                    )
                } else if let weather = weatherKitViewModel.weatherData {
                    //                    VStack(spacing: 10) {
                    VStack {
                        WeatherHeaderView(
                            weather: weather,
                            locationName: locationManagerNew.locality ?? "Loading...",
                            thoroughfare: locationManagerNew.thoroughfare ?? "Loading..."
                        )
                    }
                    .padding(.bottom, 20)
                    
                    VStack {
                        RunningGradeView(
                            grade: weatherKitViewModel.runningGrade ?? .good
                        )
                    }
                    
                    VStack {
                        RunningCoachView(
                            coach: weatherKitViewModel.runningCoach
                        )
                    }
                    .padding(.bottom, 15)
                    
                    VStack{
                        Divider()
                            .bold()
                            .overlay(Color("CardFontColor"))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 15)
                    
                    VStack {
                        HealthDataView2(
                            outdoorRuns: healthViewModel.outdoorRuns,
                            indoorRuns: healthViewModel.indoorRuns,
                            indoorRunCount: healthViewModel.allIndoorRunsThisMonth,
                            outdoorRunCount: healthViewModel.allOutdoorRunsThisMonth
                        )
                    }
                    .padding(.bottom, 15)
//                    .padding(.horizontal)
                    
//                    VStack {
//                        DistanceCalroView(
//                            activeCalories: healthViewModel.activeCalories,
//                            runningDistance: healthViewModel.runningDistance
//                        )
//                    }
//                    .padding(.horizontal)
//                    .padding(.bottom, 15)
                    
                    VStack{
                        Divider()
                            .bold()
                            .overlay(Color("CardFontColor"))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 15)
                    
                    WeatherGridView(weather: weather)
                } else {
                    LoadingView(message: "Fetching Weather...")
                }
            }
            //            .padding(.vertical)
            .refreshable {
                print("Do your refresh work here")
                await weatherKitViewModel.fetchWeatherAndEvaluateRunning()
                await healthViewModel.fetchAllHealthDataToday()
            }
            
        }
        .onAppear {
            Task {
                await weatherKitViewModel.fetchWeatherAndEvaluateRunning()
                
                await healthViewModel.requestAuthorization()
                await healthViewModel.fetchAllHealthDataToday()
                
                
                // 알림 권한 요청
                NotificationManager.shared.requestNotificationPermission()
                
                // 아침, 점심, 저녁 알림 등록
                NotificationManager.shared.scheduleDailyNotifications()
            }
        }
        .onChange(of: scenePhase) {
            Task {
                if scenePhase == .active {
                    // 포그라운드 전환 시 데이터 갱신
                    weatherKitViewModel.updateWeatherData()
                    await healthViewModel.fetchAllHealthDataToday()
                    
                } else if scenePhase == .background {
                    print("App moved to background")
                } else if scenePhase == .inactive {
                    print("App is inactive")
                }
            }
        }
        
    }
    
    private var backgroundColor: Color {
            switch weatherKitViewModel.runningGrade {
            case .good:
                return Color.blue.opacity(0.3)
            case .warning:
                return Color.orange.opacity(0.3)
            case .danger:
                return Color.red.opacity(0.3)
            default:
                return Color("BackgroundColor") // 기본 컬러
            }
        }
        
    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    WeatherView()
        .environmentObject(HealthKitViewModel.preview)
}

#Preview {
    WeatherView()
        .environment(\.colorScheme, .dark)
        .environmentObject(HealthKitViewModel.preview)
}
