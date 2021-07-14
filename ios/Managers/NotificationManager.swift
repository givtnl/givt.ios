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
            if let myDelegate = delegate as? NotificationTokenRegisteredDelegate {
                myDelegate.onNotificationTokenRegistered(token: token)
            }
        }
    }
    
    func invokeOnReceivedCelebration(collectGroupId: String) {
        for delegate in delegates {
            if let myDelegate = delegate as? NotificationReceivedCelebrationDelegate {
                myDelegate.onReceivedCelebration(collectGroupId: collectGroupId)
            }
        }
    }
    func invokeOnReceiveRecurringDonationTurnCreated(recurringDonationId: String) {
        for delegate in delegates {
            if let myDelegate = delegate as? NotificationRecurringDonationTurnCreatedDelegate {
                myDelegate.onReceivedRecurringDonationTurnCreated(recurringDonationId: recurringDonationId)
            }
        }
    }
    func invokeOnReceiveShowFeatureUpdate(featureId: Int) {
        for delegate in delegates {
            if let myDelegate = delegate as? NotificationShowFeatureUpdateDelegate {
                myDelegate.onReceiveShowFeatureUpdate(featureId: featureId)
            }
        }
    }
    func invokeOnReceiveSummaryNotification() {
        for delegate in delegates {
            if let myDelegate = delegate as? NotificationOpenSummaryDelegate {
                myDelegate.onReceiveOpenSummaryNotification()
            }
        }
    }
    
    func invokeOnReceiveYearlySummaryNotification(year: Int) {
        for delegate in delegates {
            if let myDelegate = delegate as? NotificationOpenYearlySummaryDelegate {
                myDelegate.onReceiveOpenYearlySummaryNotification(year: year)
            }
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
        getNotificationAuthorizationStatus { status in
            if status == .authorized {
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
    
    func getNotificationAuthorizationStatus(completion: @escaping (NotificationAuthorization) -> Void) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings(){ (settings) in
                completion(NotificationAuthorization(rawValue: settings.authorizationStatus.rawValue)!)
            }
        } else {
            let notificationDisabled = UIApplication.shared.currentUserNotificationSettings?.types.isEmpty
            if let notificationDisabled = notificationDisabled, !notificationDisabled {
                completion(NotificationAuthorization.authorized)
            } else {
                completion(NotificationAuthorization.denied)
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
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
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
                                completion(granted)
                            }
                        } else {
                            if settings.authorizationStatus == .authorized {
                                UIApplication.shared.registerForRemoteNotifications()
                                completion(true)
                                return
                            }
                            
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                completion(false)
                                return
                            }
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                completion(success)
                            })
                        }
                    }
                })
            }
        } else {
            getNotificationAuthorizationStatus { status in
                DispatchQueue.main.async {
                    switch(status) {
                        case .authorized:
                            UIApplication.shared.registerForRemoteNotifications()
                            completion(true)
                        break
                        default:
                            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                                completion(true)
                                DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
                            })
                        break
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
            case NotificationType.RecurringDonationTurnCreated.rawValue, NotificationType.RecurringDonationAboutToExpire.rawValue:
                if let recurringDonationId = pushNotificationInfo["RecurringDonationId"] as? String {
                    self.invokeOnReceiveRecurringDonationTurnCreated(recurringDonationId: recurringDonationId)
                }
            case NotificationType.ShowFeatureUpdate.rawValue:
                if let featureId = pushNotificationInfo["FeatureId"] as? String {
                    self.invokeOnReceiveShowFeatureUpdate(featureId: featureId.toInt)
                }
            case NotificationType.OpenSummaryNotification.rawValue:
                self.invokeOnReceiveSummaryNotification()
            case NotificationType.OpenYearlySummaryNotification.rawValue:
                guard let year = Int.init(pushNotificationInfo["Year"] as! String) else {
                    return
                }
                self.invokeOnReceiveYearlySummaryNotification(year: year)
            default:
                print("wrong type")
            LogService.shared.error(message: "Pushnotification type not known")
        }

        completionHandler(.newData)
    }
}

enum NotificationAuthorization: Int {
    case notDetermined = 0
    case denied = 1
    case authorized = 2
    case provisional = 3
    case ephemeral = 4
}

protocol NotificationManagerDelegate: class {
}

protocol NotificationTokenRegisteredDelegate: NotificationManagerDelegate {
    func onNotificationTokenRegistered(token: String?)
}

protocol NotificationReceivedCelebrationDelegate: NotificationManagerDelegate {
    func onReceivedCelebration(collectGroupId: String)
}

protocol NotificationRecurringDonationTurnCreatedDelegate: NotificationManagerDelegate {
    func onReceivedRecurringDonationTurnCreated(recurringDonationId: String)
}

protocol NotificationShowFeatureUpdateDelegate: NotificationManagerDelegate {
    func onReceiveShowFeatureUpdate(featureId: Int)
}

protocol NotificationOpenSummaryDelegate: NotificationManagerDelegate {
    func onReceiveOpenSummaryNotification()
}

protocol NotificationOpenYearlySummaryDelegate: NotificationManagerDelegate {
    func onReceiveOpenYearlySummaryNotification(year: Int)
}
