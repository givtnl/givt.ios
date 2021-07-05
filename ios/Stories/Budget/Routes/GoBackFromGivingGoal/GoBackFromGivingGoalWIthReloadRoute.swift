//
//  GoBackFromGivingGoalWIthReloadRoute.swift
//  ios
//
//  Created by Mike Pattyn on 23/06/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class GoBackFromGivingGoalWithReloadRoute: NoResponseRequest {
    var needsReload: Bool
    init(needsReload: Bool) {
        self.needsReload = needsReload
    }
}
