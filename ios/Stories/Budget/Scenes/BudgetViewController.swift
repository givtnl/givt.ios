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
    @IBOutlet weak var monthlyCardBody: CardViewBody!
    
    @IBOutlet weak var chartViewHeader: CardViewHeader!
    @IBOutlet weak var chartViewBody: ChartViewBody!
    
    // stuff for the chart
    private weak var axisFormatDelegate: AxisValueFormatter?
    private var months: [String]!
    
    override func viewDidLoad() {
        
        axisFormatDelegate = self

        monthlySummaryTile.amountLabel.text = "€5"
        monthlySummaryTile.descriptionLabel.text = "deze maand gegeven"
        givtNowButton.setTitle("Ik wil nu geven", for: .normal)
        monthlyCardHeader.label.text = "Februari".lowercased()
        
        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let chartValues = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
                
        setChart(dataPoints: months, values: chartValues, chartView: chartViewBody.chartView)
        setupChart(chart: chartViewBody.chartView)
        
        let ll = ChartLimitLine(limit: (chartValues.reduce(0, +)/12))
        ll.lineColor = ColorHelper.GivtLightGreen
        ll.lineDashLengths = [4.0]
        chartViewBody.chartView.rightAxis.addLimitLine(ll)
    }
    
    @IBAction func backButton(_ sender: Any) {
        try? mediater.send(request: BackToMainRoute(), withContext: self)
    }
}

extension BudgetViewController: AxisValueFormatter {
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
            
    }
    
    func setupChart(chart: BarChartView) {
        chart.getAxis(.left).drawGridLinesEnabled = false
        chart.getAxis(.right).drawGridLinesEnabled = false
        
        chart.getAxis(.left).drawAxisLineEnabled = false
        chart.getAxis(.right).drawAxisLineEnabled = false
        
        chart.getAxis(.left).drawLabelsEnabled = false
        chart.getAxis(.right).drawLabelsEnabled = false
        
        
        let xAxis = chart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false;
        xAxis.labelCount = 12
        xAxis.valueFormatter = axisFormatDelegate
        xAxis.labelFont = UIFont(name: "Avenir-Light", size: 12)!
        xAxis.drawAxisLineEnabled = false
        
        chart.data?.setDrawValues(false)
        
        chart.legend.enabled = false
        chart.isUserInteractionEnabled = false
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return months[Int(value)].lowercased()
    }
}
