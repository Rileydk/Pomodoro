//
//  Notification.swift
//  Pomodoro
//
//  Created by Riley Lai on 2023/1/14.
//

import Foundation
import UserNotifications

class CountdownNotification {
    enum CountdownNotification {
        case countdownFinished(String)

        var contentTitle: String {
            switch self {
            case .countdownFinished(let title):
                return "\(title)時間結束！"
            }
        }
    }

    static let notificationCenter = UNUserNotificationCenter.current()

    /// Register a notification that will trigger after specific duration
    /// - Parameters:
    ///   - type: Specify the countdown type. It will show on the notification alert.
    ///   - startDate: Put Date() as the parameter.
    ///   - seconds: When will the notification get triggered.
    ///              The default value is nil, which will trigger the notification instantly.
    static func registerNotification(
        type: TimerViewModel.CountdownType,
        startAt startDate: Date,
        durationBySeconds seconds: Int? = nil) {
            var trigger: UNCalendarNotificationTrigger?

            if let seconds = seconds {
                guard let endDate = startDate.endDate(afterSeconds: seconds) else {
                    return
                }
                var dateComponent = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute, .second],
                    from: endDate)
                dateComponent.timeZone = TimeZone(identifier: TimeZone.current.abbreviation() ?? "GMT+8")
                trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
            }

            let content = UNMutableNotificationContent()
            content.title = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? ""
            content.subtitle = CountdownNotification
                .countdownFinished(type.notificationTitle).contentTitle
            content.sound = UNNotificationSound.default

            let request = UNNotificationRequest(
                identifier: UUID().new(
                    storeWithKey: UserDefaults.NotificationKey.countdownFinished),
                content: content,
                trigger: trigger)

            notificationCenter.add(request) { error in
                if let error = error {
                    print(error)
                }
            }
    }
}
