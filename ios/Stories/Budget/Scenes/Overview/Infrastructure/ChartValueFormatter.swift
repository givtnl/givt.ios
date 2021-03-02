//
//  ChartsValueFormatter.swift
//  ios
//
//  Created by Mike Pattyn on 27/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Charts
import Foundation

class ChartValueFormatter: NSObject, ValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return value.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 0)
    }
}
