//
//  BudgetViewControllerYearlyChartExtension.swift
//  ios
//
//  Created by Mike Pattyn on 01/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import Charts
import UIKit

// MARK: VC Extension With Year chart functions
extension BudgetViewController {
    func setupYearsCard() {
        var yearChartValues: [Double] = []

        let yearlySummary: [MonthlySummaryDetailModel] = try! Mediater.shared.send(request: GetMonthlySummaryQuery(
                                                                                fromDate: getFromDateForYearlyOverview(),
                                                                                tillDate: getTillDateForCurrentMonth(),
                                                                                groupType: 1,
                                                                                orderType: 0))
        yearViewBody.years = []
        yearlySummary.reversed().forEach { model in
            yearViewBody.years.append(model.Key)
            yearChartValues.append(model.Value)
        }
        //setup the chart for years
        setHorizontalChart(dataPoints:  yearViewBody.years, values: yearChartValues, chartView: yearViewBody.chartView)
    }
    private func setHorizontalChart(dataPoints: [String], values: [Double], chartView: HorizontalBarChartView) {
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
        chartDataSet.valueFont = UIFont(name: "Avenir-Black", size: 12)!
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
        xAxis.labelCount = 2
        xAxis.labelFont = UIFont(name: "Avenir-Heavy", size: 12)!
        xAxis.labelTextColor = ColorHelper.GivtPurple
        xAxis.drawAxisLineEnabled = false
        
        chartView.data?.setDrawValues(true)
        
        chartView.legend.enabled = false
        chartView.isUserInteractionEnabled = false
        
        chartView.animate(xAxisDuration: 2.0, yAxisDuration: 0)
    }
    private func getFromDateForYearlyOverview() -> String {
        var componentsForYearlySummaryComponents = DateComponents()
        componentsForYearlySummaryComponents.day = 1
        componentsForYearlySummaryComponents.month = 1
        componentsForYearlySummaryComponents.year = Calendar.current.component(.year, from: Date()) - 1
        return getMonthStringFromDateValue(value: Calendar.current.date(from: componentsForYearlySummaryComponents)!)
    }
}
