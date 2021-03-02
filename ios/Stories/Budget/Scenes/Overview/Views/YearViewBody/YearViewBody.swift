//
//  YearViewBody.swift
//  ios
//
//  Created by Mike Pattyn on 19/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//
import Charts
import UIKit

class YearViewBody: UIView {
    private weak var axisYearFormatDelegate: AxisValueFormatter?

    var years: [String] = []
    
    private var borderView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var chartView: HorizontalBarChartView!
    
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
        let bundle = Bundle(for: YearViewBody.self)
        bundle.loadNibNamed("YearViewBody", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        axisYearFormatDelegate = self
        chartView.xAxis.valueFormatter = axisYearFormatDelegate
    }
}

extension YearViewBody: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return years[Int(value)].lowercased()
    }
}
