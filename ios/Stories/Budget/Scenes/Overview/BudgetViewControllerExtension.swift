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
    func setupTerms() {
        monthlySummaryTile.descriptionLabel.text = "BudgetSummaryBalance".localized
        givtNowButton.setTitle("BudgetSummaryGiveNow".localized, for: .normal)
        
        monthlyCardHeader.label.text = getFullMonthStringFromDateValue(value: Date()).capitalized
        navigationItem.title = getFullMonthStringFromDateValue(value: Date()).capitalized
        chartViewHeader.label.text = "BudgetSummaryMonth".localized
        yearViewHeader.label.text = "BudgetSummaryYear".localized
        labelGivt.text = "BudgetSummaryGivt".localized
        labelNotGivt.text = "BudgetSummaryNotGivt".localized
        buttonSeeMore.setAttributedTitle(NSMutableAttributedString(string: "BudgetSummaryShowAll".localized,
                                      attributes: [NSAttributedString.Key.underlineStyle : true]), for: .normal)
    }
    func setupTesting() {
//        let noGivtsYet = MonthlyCardViewLine()
//        stackViewGivt.addArrangedSubview(noGivtsYet)
//        stackViewGivtHeight.constant += 22
//        let noGivtsYet2 = MonthlyCardViewLine()
//        stackViewGivt.addArrangedSubview(noGivtsYet2)
//        stackViewGivtHeight.constant += 22
        
        let noGivtsYet3 = MonthlyCardViewLine()
        noGivtsYet3.collectGroupLabel.text = "Nog geen giften"
        stackViewNotGivt.addArrangedSubview(noGivtsYet3)
        stackViewNotGivtHeight.constant += 22
        let noGivtsYet4 = MonthlyCardViewLine()
        noGivtsYet4.collectGroupLabel.text = "Nog geen giften"
        stackViewNotGivt.addArrangedSubview(noGivtsYet4)
        stackViewNotGivtHeight.constant += 22
        
    }
    func setupCollectGroupsCard() {
        let collectGroupsForCurrentMonth: [MonthlySummaryDetailModel] = try! Mediater.shared.send(request: GetMonthlySummaryQuery(
                                                                                            fromDate: getFromDateForCurrentMonth(),
                                                                                            tillDate: getTillDateForCurrentMonth(),
                                                                                            groupType: 2,
                                                                                            orderType: 0))

        if collectGroupsForCurrentMonth.count >= 2 {
            let firstTwoCollectGroups = [collectGroupsForCurrentMonth[0], collectGroupsForCurrentMonth[1]]

            firstTwoCollectGroups.forEach { model in
                let view = MonthlyCardViewLine()
                view.collectGroupLabel.text = model.Key
                view.amountLabel.text = "€ \(String(format: "%.2f", model.Value))"
                stackViewGivt.addArrangedSubview(view)
                stackViewGivtHeight.constant += 22
            }
        }
    }
    func setupMonthsCard() {
        // get values for monthly summary chart
        let monthlySummarymodels: [MonthlySummaryDetailModel] = try! Mediater.shared.send(request: GetMonthlySummaryQuery(
                                                                                    fromDate: getFromDateForMonthsChart(),
                                                                                    tillDate: getTillDateForMonthsChart(),
                                                                                    groupType: 0,
                                                                                    orderType: 0))
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
            
        var doubleValues: [Double] = []
        
        for i in 1...12 {
            let monthlySummaryValue = monthsDictionary.values.filter {$0.Index == i}.first!
            doubleValues.append(monthlySummaryValue.Value)
        }
        
        monthlySummaryTile.amountLabel.text = "€\(String(format: "%.2f", doubleValues.last!))"
                
        chartViewBody.trueAverage = doubleValues.reduce(0, +)/Double(doubleValues.count)
        chartViewBody.months = monthStrings
        setVerticalChart(dataPoints: chartViewBody.months, values: doubleValues, chartView: chartViewBody.chartView, trueAverage: chartViewBody.trueAverage)
    }
    func setupYearsCard() {
        var yearChartValues: [Double] = []

        let yearlySummary: [MonthlySummaryDetailModel] = try! Mediater.shared.send(request: GetMonthlySummaryQuery(
                                                                                fromDate: getFromDateForYearlyOverview(),
                                                                                tillDate: getTillDateForCurrentMonth(),
                                                                                groupType: 1,
                                                                                orderType: 0))
        yearlySummary.reversed().forEach { model in
            yearViewBody.years.append(model.Key)
            yearChartValues.append(model.Value)
        }
        //setup the chart for years
        setHorizontalChart(dataPoints:  yearViewBody.years, values: yearChartValues, chartView: yearViewBody.chartView)
    }

}
//MARK: Private extension - used to store private methods
private extension BudgetViewController {
    @IBAction func backButton(_ sender: Any) {
        try? Mediater.shared.send(request: BackToMainRoute(), withContext: self)
    }
    @IBAction func giveNowButton(_ sender: Any) {
        try? Mediater.shared.send(request: OpenGiveNowRoute(), withContext: self)
    }
    @IBAction func buttonSeeMore(_ sender: Any) {
        print("See more pressed")
    }
    @IBAction func buttonPlus(_ sender: Any) {
        try? Mediater.shared.send(request: OpenExternalGivtsRoute(), withContext: self)
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
    private func setVerticalChart(dataPoints: [String], values: [Double], chartView: BarChartView, trueAverage: Double) {
        
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
        xAxis.labelFont = UIFont(name: "Avenir-Light", size: 12)!
        xAxis.drawAxisLineEnabled = false
        
        chartView.data?.setDrawValues(false)
        
        chartView.legend.enabled = false
        chartView.isUserInteractionEnabled = false
                
        let ll = ChartLimitLine(limit: trueAverage)
        ll.lineColor = ColorHelper.GivtLightGreen
        ll.lineDashLengths = [4.0]
        
        chartViewBody.averageButton.setTitle("€\(String(format: "%.0f", trueAverage))", for: .normal)
        chartViewBody.averageButton.ogBGColor = ColorHelper.LightGreenChart
        chartViewBody.averageButton.isEnabled = false
        
        chartView.rightAxis.addLimitLine(ll)
        
        chartView.animate(xAxisDuration: 0, yAxisDuration: 2.0)
    }

    private func getFromDateForCurrentMonth() -> String {
        let calendar = Calendar.current
        let currentDate = Date()
        let currentYear = Calendar.current.component(.year, from: currentDate)
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = currentMonth
        dateComponents.day = 1
        let date = calendar.date(from: dateComponents)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    private func getTillDateForCurrentMonth() -> String {
        let calendar = Calendar.current
        let currentDate = Date()
        let currentYear = Calendar.current.component(.year, from: currentDate)
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = currentMonth
        dateComponents.day = getDaysInMonth(month: Int(currentMonth), year: Int(currentYear))
        let date = calendar.date(from: dateComponents)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    private func getFromDateForMonthsChart() -> String {
        let currentDate = Date()
        let currentYear = Calendar.current.component(.year, from: currentDate)
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        return makeFromDateString(year: currentYear, month: currentMonth, day: 1)
    }
    private func getTillDateForMonthsChart() -> String {
        let currentDate = Date()
        let currentYear = Calendar.current.component(.year, from: currentDate)
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        let daysInMonth = getDaysInMonth(month: Int(currentMonth), year: Int(currentYear))
        return makeTillDateString(year: currentYear, month: currentMonth, day: daysInMonth)
    }
    private func getDaysInMonth(month: Int, year: Int) -> Int {
        let calendar = Calendar.current
        var startComps = DateComponents()
        startComps.day = 1
        startComps.month = month
        startComps.year = year
        var endComps = DateComponents()
        endComps.day = 1
        endComps.month = month == 12 ? 1 : month + 1
        endComps.year = month == 12 ? year + 1 : year
        let startDate = calendar.date(from: startComps)!
        let endDate = calendar.date(from:endComps)!
        let diff = calendar.dateComponents([Calendar.Component.day], from: startDate, to: endDate)
        return diff.day!
    }
    private func makeFromDateString(year: Int, month: Int, day: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: year, month: month, day: day)
        let tilDate = calendar.date(from: components)!
        var dateComponents = DateComponents()
        dateComponents.month = -11
        let fromDate = Calendar.current.date(byAdding: dateComponents, to: tilDate)
        return dateFormatter.string(from: fromDate!)
    }
    private func makeTillDateString(year: Int, month: Int, day: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: year, month: month, day: day)
        return dateFormatter.string(from: calendar.date(from: components)!)
    }
    private func getPreviousMonthDate(fromDate: Date) -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = -1
        return Calendar.current.date(byAdding: dateComponents, to: fromDate)!
    }
    private func getMonthStringFromIntValue(value: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: getDateFromInt(value: value)).replacingOccurrences(of: ".", with: String.empty)
    }
    private func getMonthStringFromDateValue(value: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: value).replacingOccurrences(of: ".", with: String.empty)
    }
    private func getDateFromInt(value: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = value
        return Calendar.current.date(from: dateComponents)!
    }
    private func getKeyValues(fromDate: Date) -> MonthlySummaryKey {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: fromDate)
        let currentMonth = calendar.component(.month, from: fromDate)
        return MonthlySummaryKey(Year: currentYear, Month: currentMonth)
    }
    private func createDateByMonthAndYear(month: Int, year: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = month
        dateComponents.year = year
        return Calendar.current.date(from: dateComponents)!
    }
    private func getFromDateForYearlyOverview() -> String {
        var componentsForYearlySummaryComponents = DateComponents()
        componentsForYearlySummaryComponents.day = 1
        componentsForYearlySummaryComponents.month = 1
        componentsForYearlySummaryComponents.year = Calendar.current.component(.year, from: Date()) - 1
        return getMonthStringFromDateValue(value: Calendar.current.date(from: componentsForYearlySummaryComponents)!)

    }
    private func getFullMonthStringFromDateValue(value: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: value).replacingOccurrences(of: ".", with: String.empty)
    }
}
