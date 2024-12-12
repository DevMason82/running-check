//
//  running_checkApp.swift
//  running-check
//
//  Created by mason on 11/17/24.
//
import SwiftUI

@main
struct running_checkApp: App {
    @StateObject private var weatherKitViewModel = WeatherKitViewModel()
    @StateObject private var locationManagerNew = LocationManagerNew()
    @StateObject private var healthViewModel = HealthKitViewModel()
    @StateObject private var notificationManager = NotificationManager.shared // Added NotificationManager
    @State private var isLoading = true // 데이터 로딩 상태
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLoading {
                    // 로딩 화면
                    LoadingView(message: "러닝체크 로딩중...🏃🏻‍♂️")
                        .transition(.opacity) // 부드러운 전환 효과 추가
                        .onAppear {
                            Task {
                                await fetchInitialData()
                            }
                        }
                } else {
                    // 모든 데이터가 로드되었을 때 WeatherView 표시
                    
                    WeatherView()
                        .environmentObject(weatherKitViewModel)
                        .environmentObject(locationManagerNew)
                        .environmentObject(healthViewModel)
                        .transition(.opacity) // 전환 효과
                    
                }
            }
            .animation(.easeInOut, value: isLoading) // 상태 변경 시 애니메이션
//            .onAppear {
//                // 요청 초기화 알림 권한
//                notificationManager.requestAuthorization()
//            }
        }
    }
    
    private func fetchInitialData() async {
        isLoading = true
        // 데이터 불러오기 순서: 위치 → 날씨 → 헬스 데이터
        await weatherKitViewModel.fetchWeatherAndEvaluateRunning()
        await healthViewModel.requestAuthorization()
        await healthViewModel.fetchAllHealthDataToday()
        notificationManager.requestNotificationPermission()
        notificationManager.scheduleDailyNotifications()
        isLoading = false
    }
}
