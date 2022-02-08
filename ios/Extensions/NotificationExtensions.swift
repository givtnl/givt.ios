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
    public static let GivtUserViewedAnnualOverview = Notification.Name("GivtUserViewedAnnualOverview")
    public static let GivtAmountPresetsSet = Notification.Name("GivtAmountPresetsSet")
    public static let GivtDidSavePresets = Notification.Name("GivtDidSavePresets")
    public static let GivtDidFindBeaconFarAway = Notification.Name("GivtDidFindBeaconFarAway")
    
    public static let GivtSegmentControlStateDidChange = Notification.Name("GivtSegmentControlStateDidChange")
    
    public static let GivtComingFromBudget = Notification.Name("GivtComingFromBudget")
    public static let GivtAmountsShouldReset = NSNotification.Name("GivtAmountsShouldReset")
}
