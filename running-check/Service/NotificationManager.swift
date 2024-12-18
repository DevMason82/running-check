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
        content.badge = NSNumber(value: 1)
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
    
    //    /// 아침, 점심, 저녁 알림 설정
    //    func scheduleDailyNotifications() {
    //        let notifications = [
    //            (identifier: "MorningNotification", title: "굿모닝 러너!", body: "상쾌한 아침! 러닝 계획을 확인하려면 앱을 열어보세요.", hour: 6, minute: 30),
    //            (identifier: "LunchNotification", title: "점심 러닝 알림", body: "점심 전 짧은 러닝으로 활력을 더해보세요. 자세한 내용은 앱에서 확인하세요!", hour: 11, minute: 30),
    //            (identifier: "EveningNotification", title: "저녁 러닝 시간!", body: "하루를 마무리하며 여유로운 러닝을 즐겨보세요. 앱에서 러닝 기록을 확인해보세요!", hour: 18, minute: 30)
    //        ]
    //
    //        for notification in notifications {
    //            scheduleDailyNotification(notification.identifier, title: notification.title, body: notification.body, hour: notification.hour, minute: notification.minute)
    //        }
    //    }
    
    /// 계절별 알림 설정
    func scheduleSeasonalDailyNotifications(for season: String) {
        var notifications: [(identifier: String, title: String, body: String, hour: Int, minute: Int)] = []
        
        switch season.lowercased() {
        case "spring", "autumn": // 봄과 가을
            notifications = [
                (identifier: "MorningNotification", title: "굿모닝 러너!", body: "아침이 상쾌해요! 오늘의 러닝 계획을 확인해보세요.", hour: 7, minute: 0),
                (identifier: "EveningNotification", title: "저녁 러닝 시간", body: "해질녘에 러닝을 즐기며 하루를 마무리해보세요.", hour: 18, minute: 30)
            ]
        case "summer": // 여름
            notifications = [
                (identifier: "EarlyMorningNotification", title: "시원한 새벽 러닝", body: "더위를 피해 이른 아침에 러닝을 시작하세요.", hour: 5, minute: 30),
                (identifier: "LateEveningNotification", title: "늦은 저녁 러닝 시간", body: "해가 진 후 시원한 바람과 함께 러닝을 즐겨보세요.", hour: 20, minute: 30)
            ]
        case "winter": // 겨울
            notifications = [
                (identifier: "LateMorningNotification", title: "늦은 아침 러닝", body: "햇살이 따뜻한 오전에 가볍게 몸을 움직여보세요.", hour: 10, minute: 30),
                (identifier: "AfternoonNotification", title: "따뜻한 오후 러닝 시간", body: "추위를 피해 따뜻한 낮에 러닝을 즐겨보세요.", hour: 14, minute: 0)
            ]
        default: // 기본값: 봄/가을 설정
            notifications = [
                (identifier: "MorningNotification", title: "굿모닝 러너!", body: "아침이 상쾌해요! 오늘의 러닝 계획을 확인해보세요.", hour: 7, minute: 0),
                (identifier: "EveningNotification", title: "저녁 러닝 시간", body: "해질녘에 러닝을 즐기며 하루를 마무리해보세요.", hour: 18, minute: 30)
            ]
        }
        
        for notification in notifications {
            scheduleDailyNotification(notification.identifier, title: notification.title, body: notification.body, hour: notification.hour, minute: notification.minute)
        }
    }
    
    /// 특정 시간에 반복 알림 등록
    private func scheduleDailyNotification(_ identifier: String, title: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.badge = NSNumber(value: 1)
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
