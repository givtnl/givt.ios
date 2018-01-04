//
//  UINavigationControllerExt.swift
//  ios
//
//  Created by Lennie Stockman on 15/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    func setLogo() {
        let img = self.givtLogo()
        self.navigationBar.setBackgroundImage(img, for: .default)
        self.navigationBar.shadowImage = UIImage()
    }
    
    func givtLogo() -> UIImage {
        let topImage = #imageLiteral(resourceName: "givt20h.png")
        let navBarWidth = self.navigationBar.frame.width
        let navBarHeight = self.navigationBar.frame.height
        let diff = UIScreen.main.bounds.height - self.view.bounds.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.height - diff
        let newSize = CGSize(width: navBarWidth, height: navBarHeight + statusBarHeight) // set this to what you need
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        let x = (newSize.width / 2) - (topImage.size.width / 2)
        let y = (navBarHeight / 2) - (topImage.size.height / 2) + statusBarHeight
        topImage.draw(in: CGRect(origin: CGPoint(x: x, y: y), size: topImage.size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func removeLogo() {
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
}

