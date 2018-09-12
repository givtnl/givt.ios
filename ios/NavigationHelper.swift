//
//  NavigationHelper.swift
//  ios
//
//  Created by Maarten Vergouwe on 27/08/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
import UIKit

class NavigationHelper {
    static func showRegistration(context: UIViewController, email: String) {
        DispatchQueue.main.async {
            let userExt = UserDefaults.standard.userExt
            userExt?.email = email
            UserDefaults.standard.userExt = userExt
            let register = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "registration") as! RegNavigationController
            context.present(register, animated: true, completion: nil)
        }
    }
    
    static func openUrl(url: URL, completion: ((Bool) -> Swift.Void)?) -> Bool {
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: completion)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url)
                completion?(true)
            }
            return true
        } else {
            return false
        }
    }
}
