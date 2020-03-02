//
//  GiftAidSettings.swift
//  ios
//
//  Created by Jonas Brabant on 28/02/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
class GiftAidSettings {
    var shouldAskForGiftAidPermission: Bool
    
    init(shouldAskForGiftAidPermission: Bool = false) {
        self.shouldAskForGiftAidPermission = shouldAskForGiftAidPermission
    }
}
