//
//  GoBackToYearlyOverviewRoute.swift
//  ios
//
//  Created by Mike Pattyn on 14/06/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class GoBackToYearlyOverviewRoute: NoResponseRequest {
    var needsReload: Bool
    init(needsReload: Bool) {
        self.needsReload = needsReload
    }
}
