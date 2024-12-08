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
                    //                    .padding(.vertical, 5)
                    
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
                    .padding(.horizontal)
                    
                    VStack {
                        DistanceCalroView(
                            activeCalories: healthViewModel.activeCalories,
                            runningDistance: healthViewModel.runningDistance
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 15)
                    
                    Divider()
                        .padding(.bottom, 15)
                        .padding(.horizontal)
                    
                    WeatherGridView(weather: weather)
                    
                    
//                    VStack(spacing: 20) {
//                        Button(action: scheduleNotification) {
//                            Text("로컬 푸시 알림 보내기")
//                                .padding()
//                                .background(Color.green)
//                                .foregroundColor(.white)
//                                .cornerRadius(10)
//                        }
//                    }
//                    .padding()
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
    
    // 로컬 알림 등록 함수
//    private func scheduleNotification() {
//        let content = UNMutableNotificationContent()
//        content.title = "SwiftUI 로컬 푸시"
//        content.body = "이것은 SwiftUI에서 발송한 테스트 로컬 알림입니다."
//        content.sound = .default
//        
//        // 5초 후에 알림 트리거
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//        
//        // 알림 요청 생성
//        let request = UNNotificationRequest(identifier: "SwiftUILocalNotification", content: content, trigger: trigger)
//        
//        // 알림 등록
//        let center = UNUserNotificationCenter.current()
//        center.add(request) { error in
//            if let error = error {
//                print("알림 등록 실패: \(error.localizedDescription)")
//            } else {
//                print("알림 등록 성공")
//            }
//        }
//    }
    
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
