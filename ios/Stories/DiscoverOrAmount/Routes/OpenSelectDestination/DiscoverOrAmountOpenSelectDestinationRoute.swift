//
//  DiscoverOrAmountOpenSelectDestinationRoute.swift
//  ios
//
//  Created by Mike Pattyn on 28/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

class DiscoverOrAmountOpenSelectDestinationRoute: NoResponseRequest {
    var action: DiscoverOrAmountActions
    
    init(action: DiscoverOrAmountActions) {
        self.action = action
    }
}
