//
//  NotificationService.swift
//  ios
//
//  Created by Bjorn Derudder on 06/02/2019.
//  Copyright © 2019 Givt. All rights reserved.
//

import Foundation
import UIKit
import AppCenter
import AppCenterPush

final class NotificationService {
    static let shared = NotificationService()
    
    func notificationsEnabled() -> Bool {
        return UIApplication.shared.isRegisteredForRemoteNotifications && !(UIApplication.shared.currentUserNotificationSettings?.types.isEmpty)!
    }
    
    func checkIfPushNotificationIdChanged() -> Bool{
        return MSAppCenter.installId()?.uuidString == UserDefaults.standard.pushnotificationId
    }
    
    func sendPushNotificationId(callback: @escaping (Bool?) -> Void) {
        
        if let pushnotId = MSAppCenter.installId()?.uuidString {
            do {
                try APIClient.shared.post(url: "api/v2/users/\(UserDefaults.standard.userExt!.guid)/pushnotificationid", data: ["PushnotificationId" : pushnotId], callback: { (response) in
                    if let response = response {
                        if (response.basicStatus == .ok){
                            UserDefaults.standard.pushnotificationId = pushnotId
                            callback(true)
                        } else {
                            if let respBody = response.text {
                                LogService.shared.error(message: "Could not update the push notification id : " + respBody)
                            } else {
                                LogService.shared.error(message: "Could not update the push notification id")
                            }
                            callback(false)
                        }
                    }
                })
            } catch{
                callback(nil)
            }
        }
    }
    
}
