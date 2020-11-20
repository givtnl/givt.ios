//
//  DiscoverOrAmountOpenSuccessRoute.swift
//  ios
//
//  Created by Mike Pattyn on 29/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

class DiscoverOrAmountOpenRecurringSuccessRoute: NoResponseRequest {
    var collectGroupName: String!
    init(collectGroupName: String) {
        self.collectGroupName = collectGroupName
    }
}
