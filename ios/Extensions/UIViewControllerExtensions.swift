//
//  UIViewControllerExtensions.swift
//  ios
//
//  Created by Lennie Stockman on 24/10/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {  
    @objc func endEditing() {
        self.view.endEditing(false)
    }
}
