//
//  NotificationManager.swift
//  ios
//
//  Created by Bjorn Derudder on 07/02/2019.
//  Copyright © 2019 Givt. All rights reserved.
//


import AppCenter
import AppCenterPush
import Foundation
import UIKit
import UserNotifications

final class NotificationManager : NSObject, MSPushDelegate {
    
    static let shared: NotificationManager = NotificationManager()
    
    let loginManager = LoginManager.shared
    let log = LogService.shared
    let client = APIClient.shared
    
    var pushServiceRunning = false
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLogin), name: .GivtUserDidLogin, object: nil)
    }
    
    func start() -> Void {
        log.info(message: "User notification status: " + String(notificationsEnabled))
        if notificationsEnabled {
            startNotificationService()
        } else {
            MSPush.setEnabled(false)
        }
        sendNotificationIdToServer()
    }
    
    func resume() -> Void {
        if notificationsEnabled {
            startNotificationService()
        } else {
            MSPush.setEnabled(false)
        }
        sendNotificationIdToServer()
    }
    
    func sendNotificationIdToServer(force: Bool = false) {
        var pushnotId: String? = nil
        if (notificationsEnabled) {
            pushnotId = MSAppCenter.installId()?.uuidString
        }
        
        if (force || notificationsEnabled != UserDefaults.standard.notificationsEnabled) && loginManager.isUserLoggedIn {
            do {
                try client.post(url: "/api/v2/users/\(UserDefaults.standard.userExt!.guid)/pushnotificationid", data: ["PushNotificationId" : pushnotId as Any], callback: { (response) in
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
                            self.startNotificationService()
                            self.sendNotificationIdToServer()
                            completion(true)
                        }
                        else {
                            completion(false)
                        }
                    }
                } else {
                    if settings.authorizationStatus == .authorized {
                        self.startNotificationService()
                        self.sendNotificationIdToServer()
                        completion(true)
                        return
                    }
                    
                    guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                        completion(false)
                        return
                    }
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        self.startNotificationService()
                        self.sendNotificationIdToServer()
                        completion(true)
                    })
                }
            })
        } else {
            if notificationsEnabled {
                startNotificationService()
                sendNotificationIdToServer()
                completion(true)
            } else {
                UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.startNotificationService()
                    self.sendNotificationIdToServer()
                    completion(true)
                })
            }
        }
    }
    
    func startNotificationService() -> Void {
        if loginManager.isUserLoggedIn {
            if !self.pushServiceRunning {
                MSPush.setDelegate(self)
                MSAppCenter.startService(MSPush.self)
                self.pushServiceRunning = true
            }
            
            if !MSPush.isEnabled() {
                MSPush.setEnabled(true)
            }
        }
    }
    
    func push(_ push: MSPush!, didReceive pushNotification: MSPushNotification!) {
        if let data = pushNotification?.customData, let payloadType = data["Type"], let type = NotificationType(rawValue: payloadType) {
            switch (type) {
            case .CelebrationActivated:
                if let collectGroupId = data["CollectGroupId"] {
                    NotificationCenter.default.post(name: .GivtReceivedCelebrationNotification, object: nil, userInfo: ["CollectGroupId": collectGroupId])
                }
                print("The celebration is activated")
            }
        } else {
            log.error(message: "Payload not correct")
        }
    }
    
    func stop() -> Void {
        
    }
    
    @objc private func userDidLogin(notification: NSNotification) {
        sendNotificationIdToServer(force: true)
    }
    
    var notificationsEnabled: Bool { get { return !(UIApplication.shared.currentUserNotificationSettings?.types.isEmpty ?? true) } }
    
    enum NotificationType: String {
        case CelebrationActivated = "CelebrationActivated"
    }
}
