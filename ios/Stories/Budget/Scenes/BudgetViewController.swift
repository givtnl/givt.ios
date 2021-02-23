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
        
        // setup the chart for months
        chartViewBody.months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let chartValues = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        setVerticalChart(dataPoints: chartViewBody.months, values: chartValues, chartView: chartViewBody.chartView)
        
        
        //setup the chart for years
        yearViewBody.years = ["2021", "2020"]
        let yearChartValues = [70, 800.0]
        setHorizontalChart(dataPoints:  yearViewBody.years, values: yearChartValues, chartView: yearViewBody.chartView)
        

        
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        try? mediater.send(request: BackToMainRoute(), withContext: self)
    }
    @IBAction func giveNowButton(_ sender: Any) {
        try? mediater.send(request: OpenGiveNowRoute(), withContext: self)
    }
}
class ChartValueFormatter: NSObject, ValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return "€ \(String(format: "%.0f", value))"
    }
}

