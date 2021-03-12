//
//  BudgetViewControllerExtension.swift
//  ios
//
//  Created by Mike Pattyn on 23/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Charts
import Foundation
import UIKit

extension BudgetViewController {
    func setHorizontalChart(dataPoints: [String], values: [Double], chartView: HorizontalBarChartView) {
        var dataEntries: [BarChartDataEntry] = []
        var chartColors: [UIColor] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
            if ((i+1) < dataPoints.count) {
                chartColors.append(ColorHelper.SoftenedGivtPurple)
            } else {
                chartColors.append(ColorHelper.LightGreenChart)
            }
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries)
        chartDataSet.colors = chartColors.reversed()
        let valuesFormatter = ChartValueFormatter()
        chartDataSet.valueFormatter = valuesFormatter
        chartDataSet.valueFont = UIFont(name: "Avenir-Black", size: 11)!
        chartDataSet.valueTextColor = .white
        
        let chartData = BarChartData(dataSet: chartDataSet)
        chartData.barWidth = 0.9
        chartView.data = chartData
        
        let leftAxis = chartView.getAxis(.left)
        let rightAxis = chartView.getAxis(.right)
        
        leftAxis.drawGridLinesEnabled = false
        rightAxis.drawGridLinesEnabled = false
        
        leftAxis.drawAxisLineEnabled = false
        rightAxis.drawAxisLineEnabled = false
        
        leftAxis.drawLabelsEnabled = false
        rightAxis.drawLabelsEnabled = false
        
        leftAxis.axisMinimum = 0
        rightAxis.axisMinimum = 0
        
        chartView.drawValueAboveBarEnabled = false
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .top
        xAxis.drawGridLinesEnabled = false;
        xAxis.drawLabelsEnabled = false
        xAxis.drawAxisLineEnabled = false

        chartView.data?.setDrawValues(true)
        
        chartView.legend.enabled = false
        chartView.isUserInteractionEnabled = false
        
        chartView.animate(xAxisDuration: 2.0, yAxisDuration: 0)
    }
    
    func setVerticalChart(dataPoints: [String], values: [Double], chartView: BarChartView, trueAverage: Double) {
        
        chartView.noDataText = "Geet gi nog gin givtn."
        chartView.noDataFont = UIFont(name: "Avenir-Book", size: 14)!
        chartView.noDataTextColor = ColorHelper.GivtPurple
        
        var dataEntries: [BarChartDataEntry] = []
        var chartColors: [UIColor] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i] )
            dataEntries.append(dataEntry)
            if ((i+1) < dataPoints.count) {
                chartColors.append(ColorHelper.SoftenedGivtPurple)
            } else {
                chartColors.append(ColorHelper.ActiveMonthForChart)
            }
        }
        
        if dataEntries.count > 0 {
            let chartDataSet = BarChartDataSet(entries: dataEntries)
            chartDataSet.colors = chartColors
            
            let chartData = BarChartData(dataSet: chartDataSet)
            
            chartView.data = chartData
        }
        
        chartView.getAxis(.left).drawGridLinesEnabled = false
        chartView.getAxis(.right).drawGridLinesEnabled = false
        
        chartView.getAxis(.left).drawAxisLineEnabled = false
        chartView.getAxis(.right).drawAxisLineEnabled = false
        
        chartView.getAxis(.left).drawLabelsEnabled = false
        chartView.getAxis(.right).drawLabelsEnabled = false
        
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false;
        xAxis.labelCount = values.count
        xAxis.valueFormatter = axisMonthFormatDelegate
        xAxis.labelFont = UIFont(name: "Avenir-Light", size: 12)!
        xAxis.drawAxisLineEnabled = false
        
        chartView.data?.setDrawValues(false)
        
        chartView.legend.enabled = false
        chartView.isUserInteractionEnabled = false
                
        let ll = ChartLimitLine(limit: trueAverage)
        ll.lineColor = ColorHelper.GivtLightGreen
        ll.lineDashLengths = [4.0]
        
        chartViewBody.averageButton.setTitle(trueAverage.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 0).split(separator: " ").joined(), for: .normal)
        chartViewBody.averageButton.ogBGColor = ColorHelper.LightGreenChart
        chartViewBody.averageButton.isEnabled = false
        
        chartView.rightAxis.addLimitLine(ll)
        chartView.minOffset = 0.0
        chartView.extraBottomOffset = 5
        
        chartView.animate(xAxisDuration: 0, yAxisDuration: 2.0)
    }
}
