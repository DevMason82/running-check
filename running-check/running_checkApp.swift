//
//  running_checkApp.swift
//  running-check
//
//  Created by mason on 11/17/24.
//

import SwiftUI
import UserNotifications

@main
struct running_checkApp: App {
//    private let notificationDelegate = NotificationDelegate()
//    init() {
//        UNUserNotificationCenter.current().delegate = notificationDelegate
//        
//        // 앱 시작 시 알림 권한 요청
//        requestNotificationPermission()
//    }
    
    var body: some Scene {
        WindowGroup {
            //            ContentView()
            WeatherView()
        }
    }
    
    // 알림 권한 요청 함수
//    private func requestNotificationPermission() {
//        let center = UNUserNotificationCenter.current()
//        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            if let error = error {
//                print("알림 권한 요청 실패: \(error.localizedDescription)")
//            } else {
//                print(granted ? "알림 권한이 허용되었습니다." : "알림 권한이 거부되었습니다.")
//            }
//        }
//    }
}

// 알림을 처리하기 위한 delegate 클래스
//class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
//    func userNotificationCenter(
//        _ center: UNUserNotificationCenter,
//        willPresent notification: UNNotification,
//        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
//    ) {
//        // 앱이 활성화된 상태에서도 배너와 소리를 표시
//        completionHandler([.banner, .sound])
//    }
//}
