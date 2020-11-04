//
//  GoToPushNotificationRequestRoute.swift
//  ios
//
//  Created by Bjorn Derudder on 16/09/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

class GoToPushNotificationViewRoute: NoResponseRequest {
    var notificationAuthorization: NotificationAuthorization
    init(notificationAuthorization: NotificationAuthorization) {
        self.notificationAuthorization = notificationAuthorization
    }
}
