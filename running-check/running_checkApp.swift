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
    @StateObject private var weeklyRunningDataViewModel = WeeklyRunningDataViewModel()
    @State private var isLoading = true // 데이터 로딩 상태
    @State private var path: [AnyHashable] = []
    @Environment(\.scenePhase) private var scenePhase // 앱 상태 감지
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
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
                            .environmentObject(weeklyRunningDataViewModel)
                            .transition(.opacity) // 전환 효과
                        
                    }
                }
                
                .animation(.easeInOut, value: isLoading) // 상태 변경 시 애니메이션
                .onChange(of: scenePhase) {
                    if scenePhase == .active {
                        // 앱 활성화 시 배지 초기화
                        notificationManager.clearBadgeCount()
                    }
                }
            }
        }
    }
    
    private func fetchInitialData() async {
        isLoading = true
        
        // 데이터 불러오기 순서: 위치 → 날씨 → 헬스 데이터
        await weatherKitViewModel.fetchWeatherAndEvaluateRunning()
        await healthViewModel.requestAuthorization()
        await healthViewModel.fetchAllHealthDataToday()
        await weeklyRunningDataViewModel.fetchWeeklyRunningData()
        
        // 알림 권한 요청
        notificationManager.requestNotificationPermission()
        
        // 계절별 알림 스케줄링
        let currentSeason = getCurrentSeason()
        print("Season:", currentSeason)
        notificationManager.scheduleSeasonalDailyNotifications(for: currentSeason)
        
        isLoading = false
    }
    
    /// 현재 계절 반환
    private func getCurrentSeason() -> String {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 3...5:
            return "spring" // 봄
        case 6...8:
            return "summer" // 여름
        case 9...11:
            return "autumn" // 가을
        default:
            return "winter" // 겨울
        }
    }
}
