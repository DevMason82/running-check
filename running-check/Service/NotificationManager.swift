//
//  NotificationManager.swift
//  running-check
//
//  Created by mason on 12/8/24.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate,ObservableObject {
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    /// 알림 권한 요청
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("알림 권한 요청 실패: \(error.localizedDescription)")
            } else {
                print(granted ? "알림 권한이 허용되었습니다." : "알림 권한이 거부되었습니다.")
            }
        }
    }

    /// 특정 시간에 로컬 알림 등록
    func scheduleNotification(identifier: String, title: String, body: String, timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 등록 실패: \(error.localizedDescription)")
            } else {
                print("알림 등록 성공: \(identifier)")
            }
        }
    }

    /// 아침, 점심, 저녁 알림 설정
    func scheduleDailyNotifications() {
        let notifications = [
            (identifier: "MorningNotification", title: "굿모닝 러너!", body: "상쾌한 아침! 러닝 계획을 확인하려면 앱을 열어보세요.", hour: 6, minute: 30),
            (identifier: "LunchNotification", title: "점심 러닝 알림", body: "점심 전 짧은 러닝으로 활력을 더해보세요. 자세한 내용은 앱에서 확인하세요!", hour: 11, minute: 30),
            (identifier: "EveningNotification", title: "저녁 러닝 시간!", body: "하루를 마무리하며 여유로운 러닝을 즐겨보세요. 앱에서 러닝 기록을 확인해보세요!", hour: 18, minute: 30)
        ]

        for notification in notifications {
            scheduleDailyNotification(notification.identifier, title: notification.title, body: notification.body, hour: notification.hour, minute: notification.minute)
        }
    }

    /// 특정 시간에 반복 알림 등록
    private func scheduleDailyNotification(_ identifier: String, title: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 등록 실패: \(error.localizedDescription)")
            } else {
                print("알림 등록 성공: \(identifier)")
            }
        }
    }

    // MARK: - UNUserNotificationCenterDelegate Methods

    /// Foreground 상태에서 알림 표시
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound]) // Foreground 상태에서도 알림 표시
    }

    /// 알림 탭 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("알림을 클릭했습니다: \(response.notification.request.identifier)")
        completionHandler()
    }
}
