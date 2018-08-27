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
}
