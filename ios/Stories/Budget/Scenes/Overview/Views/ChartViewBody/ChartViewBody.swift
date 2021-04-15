//
//  ChartViewBody.swift
//  ios
//
//  Created by Mike Pattyn on 18/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//
import Charts
import UIKit

class ChartViewBody: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var chartView: BarChartView!
    @IBOutlet weak var averageButton: CustomButton!
    
    var months: [String] = []
    var trueAverage: Double = 0
    private weak var axisMonthFormatDelegate: AxisValueFormatter?
    private var borderView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5.0)
    }
    private func commonInit() {
        let bundle = Bundle(for: ChartViewBody.self)
        bundle.loadNibNamed("ChartViewBody", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        axisMonthFormatDelegate = self
        chartView.xAxis.valueFormatter = axisMonthFormatDelegate
        chartView.xAxis.labelTextColor = ColorHelper.GivtPurple
    }
}

extension ChartViewBody: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if Locale.current.languageCode == "en" {
            return months[Int(value)].capitalized
        } else {
            return months[Int(value)].lowercased()
        }
    }
}
