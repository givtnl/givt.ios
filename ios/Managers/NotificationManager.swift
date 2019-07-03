//
//  NotificationManager.swift
//  ios
//
//  Created by Bjorn Derudder on 07/02/2019.
//  Copyright © 2019 Givt. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

final class NotificationManager : NSObject {
    
    static let shared: NotificationManager = NotificationManager()
    
    let loginManager = LoginManager.shared
    
    let log = LogService.shared
    let client = APIClient.shared
    
    var pushServiceRunning = false
    var notificationsEnabled: Bool { get { return !(UIApplication.shared.currentUserNotificationSettings?.types.isEmpty ?? true) } }
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLogin), name: .GivtUserDidLogin, object: nil)
    }
    
    func start() -> Void {
        log.info(message: "User notification status: " + String(notificationsEnabled))
        sendNotificationIdToServer()
    }
    
    func resume() -> Void {
        sendNotificationIdToServer()
    }
    
    func sendNotificationIdToServer(force: Bool = false) {
        var pushnotId: String? = nil
        if (notificationsEnabled) {
            pushnotId = UserDefaults.standard.deviceToken
        } else {
            UserDefaults.standard.deviceToken = nil
        }
        
        if (force || notificationsEnabled != UserDefaults.standard.notificationsEnabled) && loginManager.isUserLoggedIn {
            do {
                try client.post(url: "/api/v2/users/\(UserDefaults.standard.userExt!.guid)/pushnotificationid", data: ["PushNotificationId" : pushnotId as Any, "OS" : 2], callback: { (response) in
                    if let response = response {
                        if (response.basicStatus == .ok){
                            UserDefaults.standard.notificationsEnabled = self.notificationsEnabled
                            self.log.info(message: "PushNotificationId updated")
                        } else {
                            if let respBody = response.text {
                                self.log.error(message: "Could not update the PushNotificationId: " + respBody)
                            } else {
                                self.log.error(message: "Could not update the PushNotificationId")
                            }
                        }
                    }
                })
            } catch {
                self.log.error(message: "\(error)")
            }
        }
    }
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void ) -> Void {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings(completionHandler: {(settings) in
                if settings.authorizationStatus == .notDetermined {
                    center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                        if granted {
                            UIApplication.shared.registerForRemoteNotifications()
                            completion(true)
                        }
                        else {
                            completion(false)
                        }
                    }
                } else {
                    if settings.authorizationStatus == .authorized {
                        UIApplication.shared.registerForRemoteNotifications()
                        completion(true)
                        return
                    }
                    
                    guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                        completion(false)
                        return
                    }
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        UIApplication.shared.registerForRemoteNotifications()
                        completion(true)
                    })
                }
            })
        } else {
            if notificationsEnabled {
                if let _ = UserDefaults.standard.deviceToken {
                    completion(true)
                } else {
                    UIApplication.shared.registerForRemoteNotifications()
                    completion(true)
                }
            } else {
                UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                    completion(true)
                })
            }
        }
    }
    
    func stop() -> Void {
        
    }
    
    @objc private func userDidLogin(notification: NSNotification) {
        sendNotificationIdToServer(force: true)
    }
    
    func processRegisterForRemoteNotifications(deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        UserDefaults.standard.deviceToken = token
        sendNotificationIdToServer()
    }
    
    func processPushNotification(fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void, pushNotificationInfo: [AnyHashable: Any] ) {
        guard let aps = pushNotificationInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }

        guard let type = pushNotificationInfo["type"] as? String else  {
            completionHandler(.failed)
            LogService.shared.error(message: "Pushnotification type not of string-type")
            return
        }
        
        switch type {
            case NotificationType.CelebrationActivated.rawValue:
                if let collectGroupId = pushNotificationInfo["CollectGroupId"] {
                    NotificationCenter.default.post(name: .GivtReceivedCelebrationNotification, object: nil, userInfo: ["CollectGroupId": collectGroupId])
            }
            case NotificationType.ProcessCachedGivts.rawValue:
                print("process cached givts action")
                GivtManager.shared.processCachedGivts()
            default:
                print("wrong type")
            LogService.shared.error(message: "Pushnotification type not known")
        }
        
        print(aps)
        completionHandler(.newData)
    }
}
