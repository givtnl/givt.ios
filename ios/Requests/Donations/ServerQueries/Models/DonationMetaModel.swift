//
//  DonationMetaModel.swift
//  ios
//
//  Created by Maarten Vergouwe on 20/01/2022.
//  Copyright © 2022 Givt. All rights reserved.
//

import Foundation

struct DonationMetaModel : Codable {
    struct GiftAidSettingsModel : Codable {
        var ShouldAskForGiftAidPermission: Bool
    }
    
    var HasDeductableGivts : Bool
    var AccountType : String
    var YearsWithGivts : [Int]?
    var GiftAidSettings: GiftAidSettingsModel?
}
