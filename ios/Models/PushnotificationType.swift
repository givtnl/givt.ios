//
//  PushnotificationType.swift
//  ios
//
//  Created by Jonas Brabant on 03/07/2019.
//  Copyright © 2019 Givt. All rights reserved.
//
import Foundation
public enum NotificationType: String {
    case CelebrationActivated = "CelebrationActivated"
    case ProcessCachedGivts = "ProcessCachedGivts"
    case RecurringDonationTurnCreated = "RecurringDonationTurnCreated"
    case ShowFeatureUpdate = "ShowFeatureUpdate"
    case RecurringDonationAboutToExpire = "RecurringDonationAboutToExpire"
    case OpenSummaryNotification = "OpenSummaryNotification"
}
