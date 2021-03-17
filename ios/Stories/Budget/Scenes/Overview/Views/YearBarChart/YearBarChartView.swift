//
//  YearBarChartView.swift
//  ios
//
//  Created by Mike Pattyn on 18/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Charts
import SwiftUI

struct YearBarChartView: UIViewRepresentable {
    func makeUIView(context: Context) -> BarChartView {
        <#code#>
    }
    
    func updateUIView(_ uiView: BarChartView, context: Context) {
        <#code#>
    }
    
    typealias UIViewType = BarChartView
}

struct YearBarChartView_Previews: PreviewProvider {
    static var previews: some View {
        YearBarChartView(entries: YearMonthView.dataEntriesForYear(2000, elements: YearMonthView.allElements))
    }
}

struct YearMonthView {
    var year: Int
    var month: Double
    var quantity: Double
    
    static func dataEntriesForYear(_ year: Int, elements: [YearMonthView]) -> [BarChartDataEntry] {
        let yearElements = elements.filter {$0.year == year}
        return yearElements.map {BarChartDataEntry(x: $0.month, y: $0.quantity)}
    }
    
    static var allElements: [YearMonthView] {
        [
            YearMonthView(year: 2000, month: 1, quantity: 20)
        ]
    }
}
