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
class YearlySummaryItem {
    var year: Int
    var amount: Double
    init(year: Int, amount: Double) {
        self.year = year
        self.amount = amount
    }
}

// MARK: VC Extension With Year chart functions
extension BudgetOverviewViewController {
    func setupYearsCard() {
        var yearsWithValues: [YearlySummaryItem] = []
        
        let currentYear = Date().getYear().string.toInt
        yearsWithValues.append(YearlySummaryItem(year: currentYear-1, amount: 0))
        yearsWithValues.append(YearlySummaryItem(year: currentYear, amount: 0))
                
        let fromDate = getFromDateForYearlyOverview()
        let tillDate = getTillDateForCurrentMonth()
        
        let yearlySummary: [MonthlySummaryDetailModel] = try! Mediater.shared.send(request: GetMonthlySummaryQuery(
                                                                                    fromDate: fromDate,
                                                                                    tillDate: tillDate,
                                                                                    groupType: 1,
                                                                                    orderType: 0))
        yearViewBody.years = []
        
        yearlySummary.forEach { model in
            let item = yearsWithValues.first { $0.year == model.Key.toInt }
            item?.amount = model.Value
        }
        
        let yearlySummaryNotGivt: [MonthlySummaryDetailModel] = try! Mediater.shared.send(request: GetExternalMonthlySummaryQuery(
                                                                                            fromDate: fromDate,
                                                                                            tillDate: tillDate,
                                                                                            groupType: 1,
                                                                                            orderType: 0))
        
        yearlySummaryNotGivt.forEach { model in
            let item = yearsWithValues.first { $0.year == model.Key.toInt }
            item?.amount += model.Value
        }
        
        var yearChartValues: [Double] = []
        
        yearsWithValues.forEach { model in
            if model.amount != 0 {
                yearViewBody.years.append(model.year.string)
                yearChartValues.append(model.amount)
            }
        }
        
        if yearlySummary.count == 1 {
            yearViewBodyHeight.constant = 110
            if yearViewBody.labelStackView.arrangedSubviews.count > 1 {
                yearViewBody.labelStackView.arrangedSubviews[0].removeFromSuperview()
            }
            (yearViewBody.labelStackView.arrangedSubviews[0] as! UILabel).text = yearViewBody.years[0]
        } else if yearlySummary.count == 2 {
            (yearViewBody.labelStackView.arrangedSubviews[0] as! UILabel).text = yearViewBody.years[0]
            (yearViewBody.labelStackView.arrangedSubviews[1] as! UILabel).text = yearViewBody.years[1]
        } else {
            yearViewBodyHeight.constant = 110
            if yearViewBody.labelStackView.arrangedSubviews.count > 1 {
                yearViewBody.labelStackView.arrangedSubviews[0].removeFromSuperview()
            }
            (yearViewBody.labelStackView.arrangedSubviews[0] as! UILabel).text = Date().getYear().string
        }
        
        //setup the chart for years
        setHorizontalChart(dataPoints:  yearViewBody.years, values: yearChartValues.reversed(), chartView: yearViewBody.chartView)
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
        
        leftAxis.spaceTop = 0
        
        chartView.data?.setDrawValues(true)
        
        chartView.legend.enabled = false
        chartView.isUserInteractionEnabled = false
        
        chartView.animate(xAxisDuration: 0, yAxisDuration: 2.0)
    }
    private func getFromDateForYearlyOverview() -> String {
        var componentsForYearlySummaryComponents = DateComponents()
        componentsForYearlySummaryComponents.day = 1
        componentsForYearlySummaryComponents.month = 1
        componentsForYearlySummaryComponents.year = Calendar.current.component(.year, from: Date()) - 1
        let date = Calendar.current.date(from: componentsForYearlySummaryComponents)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}
