//
//  BudgetNavigationController.swift
//  ios
//
//  Created by Mike Pattyn on 10/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class BudgetNavigationController : UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: "Avenir-Heavy", size: 18)!, NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)]
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        if let vc = super.popViewController(animated: animated) as? BaseTrackingViewController {
            vc.customViewDidUnload()
        }
        return nil
    }
}
