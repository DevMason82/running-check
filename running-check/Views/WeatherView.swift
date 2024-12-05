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
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            
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
                    .padding(.vertical, 25)
                    
                    VStack {
                        RunningCoachView(
                            coach: weatherKitViewModel.runningCoach
                        )
                    }
                    .padding(.bottom, 15)
                    
                    VStack {
                        HealthDataView2(
                            outdoorRuns: healthViewModel.outdoorRuns,
                            indoorRuns: healthViewModel.indoorRuns
                        )
                    }
                    .padding(.bottom, 15)
                    
                    VStack {
                        DistanceCalroView(
                            activeCalories: healthViewModel.activeCalories,
                            runningDistance: healthViewModel.runningDistance
                        )
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.vertical, 15)
                        .padding(.horizontal)
                    
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
                await healthViewModel.fetchAllHealthDataToday()
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
