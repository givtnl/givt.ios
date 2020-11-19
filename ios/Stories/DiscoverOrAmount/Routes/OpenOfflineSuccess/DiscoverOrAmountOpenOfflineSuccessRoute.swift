//
//  OpenOfflineSuccessRoute.swift
//  ios
//
//  Created by Maarten Vergouwe on 19/11/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

class DiscoverOrAmountOpenOfflineSuccessRoute : NoResponseRequest {
    var collectGroupName: String!
    init(collectGroupName: String) {
        self.collectGroupName = collectGroupName
    }
}
