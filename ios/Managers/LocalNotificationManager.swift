//
//  LocalNotificationManager.swift
//  ios
//
//  Created by Mike Pattyn on 14/04/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UserNotifications

@available(iOS 10.0, *)
class LocalNotificationManager {
    static let shared: LocalNotificationManager = LocalNotificationManager()
    
    var notifications = [LocalNotification]()
    
    // To debug what local notifications have been scheduled
    func listScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            for notification in notifications {
                print(notification)
            }
        }
    }
    
    // We need this function to request permission to the user
    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted == true && error == nil {
                self.scheduleNotifications()
            }
        }
    }
    
    func schedule() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
                case .notDetermined:
                    self.requestAuthorization()
                case .authorized, .provisional:
                    self.scheduleNotifications()
                default:
                    break
            }
        }
    }
    
    private func scheduleNotifications() {
        for notification in notifications {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.sound = .default
            content.userInfo = notification.userInfo
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: notification.dateTime, repeats: notification.shouldRepeat)
            
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                guard error == nil else { return }
                print("Notification scheduled! --- ID = \(notification.id)")
            }
        }
    }
    
}

struct LocalNotification {
    var id: String
    var title: String
    var dateTime: DateComponents
    var userInfo: [String: String]
    var shouldRepeat: Bool
}

