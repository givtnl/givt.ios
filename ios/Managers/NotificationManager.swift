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

protocol NotificationManagerDelegate: class {
    func onNotificationTokenRegistered(token: String?)
    func onReceivedCelebration(collectGroupId: String)
}

final class NotificationManager : NSObject {
    static let shared: NotificationManager = NotificationManager()
    
    public var delegates = [NotificationManagerDelegate]()
    
    private let loginManager = LoginManager.shared
    
    private let log = LogService.shared
    private let client = APIClient.shared
    
    private var pushServiceRunning = false

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLogin), name: .GivtUserDidLogin, object: nil)
    }
    
    func invokeOnNotificationTokenRegistered(token: String?) {
        for delegate in delegates {
            delegate.onNotificationTokenRegistered(token: token)
        }
    }
    
    func invokeOnReceivedCelebration(collectGroupId: String) {
        for delegate in delegates {
            delegate.onReceivedCelebration(collectGroupId: collectGroupId)
        }
    }
    
    func start() -> Void {
        DispatchQueue.main.async {
            self.requestAndUpdateTokenIfNeeded()
        }
    }
    
    func resume() -> Void {
        DispatchQueue.main.async {
            self.requestAndUpdateTokenIfNeeded()
        }
    }
    
    func requestAndUpdateTokenIfNeeded(force: Bool = false) {
        areNotificationsEnabled { enabled in
            if enabled {
                if force, let token = UserDefaults.standard.deviceToken {
                    DispatchQueue.global(qos: .background).async {
                        self.updateNotificationId(token: token, force: true)
                    }
                }
                DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
            } else if UserDefaults.standard.deviceToken != nil {
                DispatchQueue.global(qos: .background).async {
                    self.updateNotificationId(token: nil)
                }
            }
        }
    }
    
    func areNotificationsEnabled(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().getNotificationSettings(){ (setttings) in
                    switch setttings.authorizationStatus{
                    case .authorized:
                        completion(true)
                    default:
                        completion(false)
                    }
                }
            } else {
                let notificationDisabled = UIApplication.shared.currentUserNotificationSettings?.types.isEmpty
                if let notificationDisabled = notificationDisabled, !notificationDisabled {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func updateNotificationId(token: String?, force: Bool = false) {
        if (force || token != UserDefaults.standard.deviceToken) && loginManager.isUserLoggedIn {
            do {
                try client.post(url: "/api/v2/users/\(UserDefaults.standard.userExt!.guid)/pushnotificationid", data: ["PushNotificationId" : token as Any, "OS" : 2], callback: { (response) in
                    if let response = response {
                        if (response.basicStatus == .ok){
                            self.log.info(message: "PushNotificationId updated")
                            UserDefaults.standard.deviceToken = token
                            self.invokeOnNotificationTokenRegistered(token: token)
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
    
    func requestNotificationPermission() -> Void {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            DispatchQueue.main.async {
                center.getNotificationSettings(completionHandler: {(settings) in
                    DispatchQueue.main.async {
                        if settings.authorizationStatus == .notDetermined {
                            center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                                if granted {
                                    UIApplication.shared.registerForRemoteNotifications()
                                }
                            }
                        } else {
                            if settings.authorizationStatus == .authorized {
                                UIApplication.shared.registerForRemoteNotifications()
                                return
                            }
                            
                            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                                return
                            }
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
                        }
                    }
                })
            }
        } else {
            self.areNotificationsEnabled { enabled in
                DispatchQueue.main.async {
                    if (enabled) {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    else {
                        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                            DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
                        })
                    }
                }
            }
        }
    }
    
    func stop() -> Void {
        
    }
    
    @objc private func userDidLogin(notification: NSNotification) {
        DispatchQueue.main.async {
            self.requestAndUpdateTokenIfNeeded(force: true)
        }
    }
    
    func processRegisterForRemoteNotifications(deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        DispatchQueue.global(qos: .background).async {
            self.updateNotificationId(token: token)
        }
    }
    
    func processPushNotification(fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void, pushNotificationInfo: [AnyHashable: Any] ) {
        guard let aps = pushNotificationInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }

        guard let type = pushNotificationInfo["Type"] as? String else  {
            completionHandler(.failed)
            LogService.shared.error(message: "Pushnotification type not of string-type")
            return
        }
        
        switch type {
            case NotificationType.CelebrationActivated.rawValue:
                if let collectGroupId = pushNotificationInfo["CollectGroupId"] as? String {
                    self.invokeOnReceivedCelebration(collectGroupId: collectGroupId)
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
