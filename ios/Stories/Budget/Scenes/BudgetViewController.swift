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
    private weak var axisMonthFormatDelegate: AxisValueFormatter?
    private weak var axisYearFormatDelegate: AxisValueFormatter?
    
    private var months: [String]!
    
    override func viewDidLoad() {
        
        axisMonthFormatDelegate = self
        axisYearFormatDelegate = yearViewBody.self

        monthlySummaryTile.amountLabel.text = "€5"
        monthlySummaryTile.descriptionLabel.text = "deze maand gegeven"
        givtNowButton.setTitle("Ik wil nu geven", for: .normal)
        
        monthlyCardHeader.label.text = "Februari".lowercased()
        chartViewHeader.label.text = "Per maand".lowercased()
        yearViewHeader.label.text = "Per jaar".lowercased()
        
        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let chartValues = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
                
        // setup the chart for months
        setChart(dataPoints: months, values: chartValues, chartView: chartViewBody.chartView)
        
        yearViewBody.years = ["2021", "2020"]
        let yearChartValues = [70.0, 800.0]
        
        setHorizontalChart(dataPoints:  yearViewBody.years, values: yearChartValues, chartView: yearViewBody.chartView)
        setupYearChart(chart: yearViewBody.chartView)
        
//        chartViewBody.chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
//        yearViewBody.chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
            
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        try? mediater.send(request: BackToMainRoute(), withContext: self)
    }
    @IBAction func giveNowButton(_ sender: Any) {
        print("Qyeet")
    }
}
class ChartValueFormatter: NSObject, ValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return "€ \(value)"
    }
}

extension BudgetViewController: AxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return months[Int(value)].lowercased()
    }
    
    func setHorizontalChart(dataPoints: [String], values: [Double], chartView: HorizontalBarChartView) {
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries)
        chartDataSet.setColor(ColorHelper.GivtPurple)
        let valuesFormatter = ChartValueFormatter()
        chartDataSet.valueFormatter = valuesFormatter
        chartDataSet.valueFont = UIFont(name: "Avenir-Light", size: 12)!
        chartDataSet.valueTextColor = .white
        
        let chartData = BarChartData(dataSet: chartDataSet)
        chartData.barWidth = 0.9
        chartView.data = chartData
        
    }
    func setChart(dataPoints: [String], values: [Double], chartView: BarChartView) {
        chartView.noDataText = "You need to provide data for the chart."
        var dataEntries: [BarChartDataEntry] = []
                
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i] )
            dataEntries.append(dataEntry)
        }
                
        let chartDataSet = BarChartDataSet(entries: dataEntries)
        chartDataSet.setColor(ColorHelper.GivtPurple)
        let chartData = BarChartData(dataSet: chartDataSet)
        
        chartView.data = chartData
        
        chartView.getAxis(.left).drawGridLinesEnabled = false
        chartView.getAxis(.right).drawGridLinesEnabled = false
        
        chartView.getAxis(.left).drawAxisLineEnabled = false
        chartView.getAxis(.right).drawAxisLineEnabled = false
        
        chartView.getAxis(.left).drawLabelsEnabled = false
        chartView.getAxis(.right).drawLabelsEnabled = false
        
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false;
        xAxis.labelCount = 12
        xAxis.valueFormatter = axisMonthFormatDelegate
        xAxis.labelFont = UIFont(name: "Avenir-Light", size: 12)!
        xAxis.drawAxisLineEnabled = false
        
        chartView.data?.setDrawValues(false)
        
        chartView.legend.enabled = false
        chartView.isUserInteractionEnabled = false
        
        let ll = ChartLimitLine(limit: (values.reduce(0, +)/12))
        ll.lineColor = ColorHelper.GivtLightGreen
        ll.lineDashLengths = [4.0]
        chartView.rightAxis.addLimitLine(ll)
    }
    
    func setupYearChart(chart: HorizontalBarChartView) {
        chart.getAxis(.left).drawGridLinesEnabled = false
        chart.getAxis(.right).drawGridLinesEnabled = false
        
        chart.getAxis(.left).drawAxisLineEnabled = false
        chart.getAxis(.right).drawAxisLineEnabled = false
        
        chart.getAxis(.left).drawLabelsEnabled = false
        chart.getAxis(.right).drawLabelsEnabled = false
        
        chart.drawValueAboveBarEnabled = false

        
        let xAxis = chart.xAxis
        xAxis.labelPosition = .top
        xAxis.drawGridLinesEnabled = false;
        xAxis.labelCount = 2
        xAxis.valueFormatter = axisYearFormatDelegate
        xAxis.labelFont = UIFont(name: "Avenir-Light", size: 12)!
        xAxis.drawAxisLineEnabled = false
                
        chart.data?.setDrawValues(true)
        
        chart.legend.enabled = false
        chart.isUserInteractionEnabled = false
    }

}
