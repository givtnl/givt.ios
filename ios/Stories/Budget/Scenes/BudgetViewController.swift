//
//  BudgetViewController.swift
//  ios
//
//  Created by Mike Pattyn on 09/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class BudgetViewController : UIViewController {
    private var mediater: MediaterWithContextProtocol = Mediater.shared

    @IBOutlet weak var monthlySummaryTile: MonthlySummary!
    @IBOutlet weak var givtNowButton: CustomButton!
    
    override func viewDidLoad() {
        monthlySummaryTile.amountLabel.text = "€5"
        monthlySummaryTile.descriptionLabel.text = "deze maand gegeven"
        givtNowButton.setTitle("Ik wil nu geven", for: .normal)
    }
    
    @IBAction func backButton(_ sender: Any) {
        try? mediater.send(request: BackToMainRoute(), withContext: self)
    }
}
