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
        chartViewHeader.label.text = "Per maand".lowercased()
        yearViewHeader.label.text = "Per jaar".lowercased()
        
        // delegates for chart formatters
        axisMonthFormatDelegate = chartViewBody.self
        axisYearFormatDelegate = yearViewBody.self
        
        
        
        
        
        
        //setup the chart for years
        yearViewBody.years = ["2021", "2020"]
        let yearChartValues = [70, 800.0]
        setHorizontalChart(dataPoints:  yearViewBody.years, values: yearChartValues, chartView: yearViewBody.chartView)
        
        // setup the chart for months
        var months: [String] = []
        var lastMonthInt = 0
        var lastMonthDate: Date?
        var monthValues: [Double] = []
        let monthlySummarymodels: [MonthlySummaryDetailModel] = try! mediater.send(request: GetMonthlySummaryQuery())
        
        monthlySummarymodels.forEach { model in
            lastMonthInt = Int(model.Key)!
            lastMonthDate = getDateFromInt(value: lastMonthInt)
            months.append(getMonthStringFromIntValue(value: lastMonthInt))
            monthValues.append(model.Value)
        }
                
        let fillCount = 12 - monthlySummarymodels.count
        
        for _ in 1...fillCount {
            let date = getPreviousMonthDate(fromDate: lastMonthDate!)
            lastMonthDate = date
            
            months.insert(getMonthStringFromDateValue(value: lastMonthDate!), at: 0)
            monthValues.insert(Double(0), at: 0)
        }
        
        chartViewBody.trueAverage = monthValues.filter{$0 != 0}.reduce(0, +)/Double(monthValues.filter{$0 != 0}.count)

        chartViewBody.months = months
        let chartValues = monthValues
        
        setVerticalChart(dataPoints: chartViewBody.months, values: chartValues, chartView: chartViewBody.chartView, trueAverage: chartViewBody.trueAverage!)
        // end of setup the chart for months

    }
    
    @IBAction func backButton(_ sender: Any) {
        try? mediater.send(request: BackToMainRoute(), withContext: self)
    }
    @IBAction func giveNowButton(_ sender: Any) {
        try? mediater.send(request: OpenGiveNowRoute(), withContext: self)
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
}

class ChartValueFormatter: NSObject, ValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return "€ \(String(format: "%.0f", value))"
    }
}

