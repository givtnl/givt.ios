//
//  BudgetListViewController.swift
//  ios
//
//  Created by Mike Pattyn on 09/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class BudgetListViewController: UIViewController, OverlayViewController {
    let overlaySize: CGSize? = CGSize(width: UIScreen.main.bounds.width * 0.9, height: 200.0)
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismissOverlay()
    }
}

