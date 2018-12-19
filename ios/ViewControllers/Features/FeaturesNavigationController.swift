//
//  FeaturesNavigationControlller.swift
//  ios
//
//  Created by Maarten Vergouwe on 19/12/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
import UIKit

class FeaturesNavigationController: UINavigationController {
    var btnBackVisible = true
    var btnSkipVisible = true
    var btnCloseVisible = true
    
    var features: [Feature]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        if let vc = self.childViewControllers.first as? FeaturesFirstViewController {
            vc.btnBackVisible = btnBackVisible
            vc.btnCloseVisible = btnCloseVisible
            vc.btnSkipVisible = btnSkipVisible
            vc.featurePages = features.first!.pages
        }
    }
}
