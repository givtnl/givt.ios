//
//  BudgetViewControllerMonthlyChartExtension.swift
//  ios
//
//  Created by Mike Pattyn on 01/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import Charts
import UIKit

// MARK: VC Extension With Monthly chart functions
extension BudgetOverviewViewController {
    func setupMonthsCard() {
        // get values for monthly summary chart
        guard let monthlySummarymodels = monthlySummaryModels else {
            return
        }
        
        // define dictionary
        var monthsDictionary: [MonthlySummaryKey: MonthlySummaryValue] = [:]
        // create the date from now
        var toUseDate = Date()
        // get this month's key value pair
        let firstKey = getKeyValues(fromDate: toUseDate)
        // add they key to the dictionary
        monthsDictionary[firstKey] = MonthlySummaryValue(Index: 12, Value: 0.0)
        // now loop untill we get dict with 12 key value pairs
        var i = monthsDictionary.count
        
        // array for month strings
        var monthStrings: [String] = []
        // get the current moths string value
        monthStrings.insert(getMonthStringFromDateValue(value: toUseDate), at: 0)
        // start looping to fill array with place holder values
        while i < 12 {
            let prevDate = getPreviousMonthDate(fromDate: toUseDate)
            toUseDate = prevDate
            monthStrings.insert(getMonthStringFromDateValue(value: toUseDate), at: 0)
            let nextKey = getKeyValues(fromDate: prevDate)
            monthsDictionary[nextKey] = MonthlySummaryValue(Index: 12 - i, Value: 0.0)
            i += 1
        }
        
        // now loop over the results from the query to fill it with the actual values
        monthlySummarymodels.forEach { model in
            // get our key model from the result key
            let keyValues = MonthlySummaryKey(Year: Int(model.Key.split(separator: "-")[0])!, Month: Int(model.Key.split(separator: "-")[1])!)
            // update the key value pair
            monthsDictionary[keyValues]?.Value = model.Value
        }
            
        guard let monthlySummaryNotGivt = monthlySummaryModelsNotGivt else {
            return
        }
        
        monthlySummaryNotGivt.forEach { model in
            let keyValues = MonthlySummaryKey(Year: Int(model.Key.split(separator: "-")[0])!, Month: Int(model.Key.split(separator: "-")[1])!)
            monthsDictionary[keyValues]?.Value += model.Value
        }
        
        var doubleValues: [Double] = []
        
        for i in 1...12 {
            let monthlySummaryValue = monthsDictionary.values.filter {$0.Index == i}.first!
            doubleValues.append(monthlySummaryValue.Value)
        }
                
        var placeholderDoubles = doubleValues
        placeholderDoubles.removeLast()
        placeholderDoubles = placeholderDoubles.filter{$0 != 0}

        var average = 0.0
        if placeholderDoubles.count >= 1 {
            average = placeholderDoubles.reduce(0, +)/Double(placeholderDoubles.count)
        }
        chartViewBody.trueAverage = average
        chartViewBody.months = monthStrings
        setVerticalChart(dataPoints: chartViewBody.months, values: doubleValues, chartView: chartViewBody.chartView, trueAverage: chartViewBody.trueAverage)
    }
    private func setVerticalChart(dataPoints: [String], values: [Double], chartView: BarChartView, trueAverage: Double) {
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
        
        let lineLimit = givingGoal != nil ? givingGoal!.periodicity == 0 ? givingGoal!.amount : givingGoal!.amount / 12 : trueAverage

        if dataEntries.count > 0 {
            let limitBarChartDataEntry = BarChartDataEntry(x: 0, y: lineLimit)
            dataEntries.append(limitBarChartDataEntry)
            chartColors.append(.clear)
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
        xAxis.labelFont = UIFont(name: "Avenir-Light", size: 12)!
        xAxis.drawAxisLineEnabled = false
        
        chartView.data?.setDrawValues(false)
        
        chartView.legend.enabled = false
        chartView.isUserInteractionEnabled = false
        
        
        let ll = ChartLimitLine(limit: lineLimit)
        ll.lineColor = ColorHelper.GivtLightGreen
        ll.lineDashLengths = [4.0]
        chartView.rightAxis.removeAllLimitLines()
        chartView.rightAxis.addLimitLine(ll)
                
        chartViewBody.averageButton.setTitle(lineLimit.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 0, withSpace: false), for: .normal)
        chartViewBody.averageButton.ogBGColor = ColorHelper.LightGreenChart
        chartViewBody.averageButton.isEnabled = false
        
        chartView.minOffset = 0
        chartView.extraBottomOffset = 4
        
        chartView.animate(xAxisDuration: 0, yAxisDuration: 2.0)
    }
    private func getKeyValues(fromDate: Date) -> MonthlySummaryKey {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: fromDate)
        let currentMonth = calendar.component(.month, from: fromDate)
        return MonthlySummaryKey(Year: currentYear, Month: currentMonth)
    }
    func getFromDateForMonthsChart() -> String {
        let currentDate = Date()
        let currentYear = Calendar.current.component(.year, from: currentDate)
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        return makeFromDateString(year: currentYear, month: currentMonth, day: 1)
    }
    func getTillDateForMonthsChart() -> String {
        let currentDate = Date()
        let currentYear = Calendar.current.component(.year, from: currentDate)
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        let daysInMonth = getDaysInMonth(month: Int(currentMonth), year: Int(currentYear))
        return makeTillDateString(year: currentYear, month: currentMonth, day: daysInMonth)
    }
}
