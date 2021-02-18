//
//  MonthlyOverviewCellViewModel.swift
//  ios
//
//  Created by Mike Pattyn on 17/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

struct MonthlyOverviewCellViewModel {
    public var collectGroupName: String = ""
    init(collectGroupName: String) {
        self.collectGroupName = collectGroupName
    }
}
