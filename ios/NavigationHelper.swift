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
    static func showRegistration(context: UIViewController, email: String, password: String? = nil) {
        DispatchQueue.main.async {
            let userExt = UserDefaults.standard.userExt
            userExt?.email = email
            UserDefaults.standard.userExt = userExt
            let register = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "registration") as! RegNavigationController
            if let countryFromSim = AppServices.getCountryFromSim() {
                switch(countryFromSim) {
                case "US":
                    let registrationViewController = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "USRegistrationEmailPW") as! USRegistrationViewController
                    registrationViewController.setPassword = password
                    register.setViewControllers([registrationViewController], animated: false)
                    break
                default:
                    let registrationViewController = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "RegistrationEmailPW") as! RegistrationViewController
                    registrationViewController.passwordField = password
                    register.setViewControllers([registrationViewController], animated: false)
                    break
                }
            }
            context.present(register, animated: true, completion: nil)
        }
    }
    static func openUrl(url: URL, completion: ((Bool) -> Swift.Void)?) -> Bool {
        if url.absoluteString.starts(with: "http") || UIApplication.shared.canOpenURL(url) {
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
