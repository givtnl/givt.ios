//
//  BudgetViewController.swift
//  ios
//
//  Created by Mike Pattyn on 09/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class BudgetViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthlyOverviewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MonthlyOverviewCell.self), for: indexPath) as! MonthlyOverviewCell
        let rule = self.monthlyOverviewData[indexPath.row]
        cell.viewModel = rule
        return cell
    }
    
    private var mediater: MediaterWithContextProtocol = Mediater.shared

    @IBOutlet weak var monthlySummaryTile: MonthlySummary!
    @IBOutlet weak var givtNowButton: CustomButton!
    @IBOutlet weak var monthlyOverviewTable: UITableView!
    private var monthlyOverviewData: [MonthlyOverviewCellViewModel] = []
    
    override func viewDidLoad() {
        monthlySummaryTile.amountLabel.text = "€5"
        monthlySummaryTile.descriptionLabel.text = "deze maand gegeven"
        givtNowButton.setTitle("Ik wil nu geven", for: .normal)
        
        monthlyOverviewTable.delegate = self
        monthlyOverviewTable.dataSource = self
        
        
        var monthlyOverviewModel = MonthlyOverviewCellViewModel()
        monthlyOverviewModel.collectGroupName = "Qyeet"
        monthlyOverviewData.append(monthlyOverviewModel)
        
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        try? mediater.send(request: BackToMainRoute(), withContext: self)
    }
}
