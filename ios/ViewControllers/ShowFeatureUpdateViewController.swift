//
//  ShowFeatureUpdateViewController.swift
//  ios
//
//  Created by Mike Pattyn on 24/11/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import Foundation

class ShowUpdateFeatureViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var buttonNext: CustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabels()
    }
    
    @IBAction func buttonNextTouched(_ sender: Any) {
        
    }
}

extension ShowUpdateFeatureViewController {
    private func setupLabels() {
        titleLabel.text = "UpdateAlertTitle".localized
        messageLabel.text = "UpdateAlertMessage".localized
        buttonNext.setTitle("Next".localized, for: .normal)
    }
}
