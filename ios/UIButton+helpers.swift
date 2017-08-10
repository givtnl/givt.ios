//
//  UIButton+helpers.swift
//  ios
//
//  Created by Lennie Stockman on 09/08/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation
import UIKit
extension UIButton {
    func loadingIndicator(show: Bool) {
        if show {
            let indicator = UIActivityIndicatorView()
            let buttonHeight = self.bounds.size.height
            let buttonWidth = self.bounds.size.width
            indicator.center = CGPoint(x: buttonWidth/2, y: buttonHeight/2)
            self.addSubview(indicator)
            indicator.startAnimating()
            self.setTitleColor(UIColor.init(white: 255, alpha: 0), for: .normal)
        } else {
            for view in self.subviews {
                if let indicator = view as? UIActivityIndicatorView {
                    indicator.stopAnimating()
                    indicator.removeFromSuperview()
                    self.setTitleColor(UIColor.init(white: 255, alpha: 1), for: .normal)
                }
            }
        }
    }
}
