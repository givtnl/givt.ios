//
//  FirstDestinationThenAmountNavigationController.swift
//  ios
//
//  Created by Maarten Vergouwe on 21/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class FirstDestinationThenAmountNavigationController : UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: "Avenir-Heavy", size: 18)!, NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)]
    }
}
