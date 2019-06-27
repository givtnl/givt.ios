//
//  LocalNotificationManager.swift
//  ios
//
//  Created by Mike Pattyn on 25/06/2019.
//  Copyright © 2019 Givt. All rights reserved.
//

import Foundation
import UserNotifications

@available(iOS 10.0, *)
class LocalNotificationManager {
    var notifications = [GivtNotification]()
    func listScheduledCenter() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            for notification in notifications {
                print(notification)
            }
        }
    }
    func schedule() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch(settings.authorizationStatus){
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                self.scheduleNotifications()
            default:
                break
            }
        }
    }
    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted == true && error == nil {
                self.scheduleNotifications()
            }
        }
    }
    private func scheduleNotifications() {
        for notification in notifications {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.sound = .default()
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 20, repeats: false)

            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) {(error) in
                guard error == nil else { return }
                print("Notification scheduled! --- ID =\(notification.id)")
            }
        }
    }
}

struct GivtNotification {
    var id: String
    var title: String
}
