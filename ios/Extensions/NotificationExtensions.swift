//
//  NotificationExtensions.swift
//  ios
//
//  Created by Lennie Stockman on 02/10/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation

extension Notification.Name {
    public static let GivtBadgeNumberDidChange = Notification.Name("GivtBadgeNumberDidChange")
    public static let GivtConnectionStateDidChange = Notification.Name("GivtConnectionStateDidChange")
    public static let GivtDidShowFeature = Notification.Name("GivtDidShowFeature")
    public static let GivtUserDidLogin = Notification.Name("GivtUserDidLogin")
}
