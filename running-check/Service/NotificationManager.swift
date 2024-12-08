//
//  NotificationManager.swift
//  running-check
//
//  Created by mason on 12/8/24.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
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
    func scheduleNotification(
        identifier: String,
        title: String,
        body: String,
        hour: Int,
        minute: Int
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        // 트리거 생성 (지정된 시간)
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // 알림 요청 생성
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // 알림 등록
        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error = error {
                print("알림 등록 실패: \(error.localizedDescription)")
            } else {
                print("알림 등록 성공: \(title) - \(hour):\(minute)")
            }
        }
    }

    /// 아침, 점심, 저녁 알림 설정
    func scheduleDailyNotifications() {
        let notifications = [
            (identifier: "MorningNotification", title: "좋은 아침입니다!", body: "아침 운동을 시작해보세요!", hour: 8, minute: 0),
            (identifier: "LunchNotification", title: "점심 시간!", body: "점심 전 산책은 어떠신가요?", hour: 12, minute: 0),
            (identifier: "EveningNotification", title: "좋은 저녁입니다!", body: "저녁 러닝으로 하루를 마무리하세요!", hour: 17, minute: 0)
        ]

        for notification in notifications {
            scheduleNotification(
                identifier: notification.identifier,
                title: notification.title,
                body: notification.body,
                hour: notification.hour,
                minute: notification.minute
            )
        }
    }
}
