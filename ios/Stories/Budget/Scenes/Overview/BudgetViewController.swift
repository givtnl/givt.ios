//
//  BudgetViewController.swift
//  ios
//
//  Created by Mike Pattyn on 09/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//
import Charts
import Foundation
import UIKit

class BudgetViewController : UIViewController {
    private var mediater: MediaterWithContextProtocol = Mediater.shared
    
    @IBOutlet weak var monthlySummaryTile: MonthlySummary!
    
    @IBOutlet weak var givtNowButton: CustomButton!
    
    @IBOutlet weak var monthlyCardHeader: CardViewHeader!
    @IBOutlet weak var monthlyCardBody: MonthlyCardViewBody!
    @IBOutlet weak var monthlyCardViewBodyHeight: NSLayoutConstraint!
    
    @IBOutlet weak var chartViewHeader: CardViewHeader!
    @IBOutlet weak var chartViewBody: ChartViewBody!
    
    @IBOutlet weak var yearViewHeader: CardViewHeader!
    @IBOutlet weak var yearViewBody: YearViewBody!
    
    
    // stuff for the chart
    weak var axisMonthFormatDelegate: AxisValueFormatter?
    weak var axisYearFormatDelegate: AxisValueFormatter?
    
    private var months: [String]!
    
    override func viewDidLoad() {
        monthlySummaryTile.amountLabel.text = "€5"
        monthlySummaryTile.descriptionLabel.text = "deze maand gegeven"
        givtNowButton.setTitle("Ik wil nu geven", for: .normal)
        
        monthlyCardHeader.label.text = "Februari".lowercased()
        
        let collectGroupsForCurrentMonth: [MonthlySummaryDetailModel] = try! mediater.send(request: GetMonthlySummaryQuery(
                                                                                            fromDate: getFromDateForCurrentMonth(),
                                                                                            tillDate: getTillDateForCurrentMonth(),
                                                                                            groupType: 2,
                                                                                            orderType: 0))

        if collectGroupsForCurrentMonth.count > 0 {
            collectGroupsForCurrentMonth.forEach { model in
                let view = MonthlyCardViewLine()
                view.collectGroupLabel.text = model.Key
                view.amountLabel.text = "€\(String(format: "%.2f", model.Value))"
                monthlyCardBody.stackView.addArrangedSubview(view)
                monthlyCardViewBodyHeight.constant += 22
            }
        }
        
        chartViewHeader.label.text = "Per maand".lowercased()
        yearViewHeader.label.text = "Per jaar".lowercased()
        
        // delegates for chart formatters
        axisMonthFormatDelegate = chartViewBody.self
        axisYearFormatDelegate = yearViewBody.self

        //setup the chart for years
        yearViewBody.years = ["2021", "2020"]
        let yearChartValues = [70, 800.0]
        setHorizontalChart(dataPoints:  yearViewBody.years, values: yearChartValues, chartView: yearViewBody.chartView)
        
//        // setup the chart for months
//        var lastMonthInt = 0
//        var lastMonthDate: Date?
//        var monthValues: [Double] = []
//
        // get values for monthly summary chart
        let monthlySummarymodels: [MonthlySummaryDetailModel] = try! mediater.send(request: GetMonthlySummaryQuery(
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
        
        
        print(monthsDictionary.count)
        
        chartViewBody.trueAverage = doubleValues.reduce(0, +)/Double(doubleValues.count)
        chartViewBody.months = monthStrings
        setVerticalChart(dataPoints: chartViewBody.months, values: doubleValues, chartView: chartViewBody.chartView, trueAverage: chartViewBody.trueAverage)
        // end of setup the chart for months

    }
    
    @IBAction func backButton(_ sender: Any) {
        try? mediater.send(request: BackToMainRoute(), withContext: self)
    }
    @IBAction func giveNowButton(_ sender: Any) {
        try? mediater.send(request: OpenGiveNowRoute(), withContext: self)
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
        let currentYear = Calendar.current.component(.year, from: fromDate)
        let currentMonth = Calendar.current.component(.month, from: fromDate)
        return MonthlySummaryKey(Year: currentYear, Month: currentMonth)
    }
    private func createDateByMonthAndYear(month: Int, year: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = month
        dateComponents.year = year
        return Calendar.current.date(from: dateComponents)!
    }
}

class ChartValueFormatter: NSObject, ValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return "€ \(String(format: "%.0f", value))"
    }
}

