//
//  UserDetailModel.swift
//  ios
//
//  Created by Maarten Vergouwe on 16/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

public struct LocalUserConfigurationModel {
    var userId: UUID?
    var paymentType: PaymentType
    var giftAidEnabled: Bool
    var mandateSigned: Bool
}
