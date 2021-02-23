//
//  ChartViewBody.swift
//  ios
//
//  Created by Mike Pattyn on 18/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//
import Charts
import UIKit

class ChartViewBody: UIView, AxisValueFormatter {
    var months: [String] = []
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return months[Int(value)].lowercased()
    }
    
    private var borderView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var chartView: BarChartView!
    @IBOutlet weak var averageButton: CustomButton!
    
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
    }
}
