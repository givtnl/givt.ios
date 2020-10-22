//
//  OpenRecurringRuleDetailFromNotificationRouteHandler.swift
//  ios
//
//  Created by Mike Pattyn on 22/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class OpenRecurringRuleDetailFromNotificationRouteHandler : RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        SVProgressHUD.show()
        NavigationManager.shared.executeWithLogin(context: context) {
            if !LoginManager.shared.isUserLoggedIn {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "SomethingWentWrong".localized, message: "Ti twa ni just", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    }))
                    context.present(alert, animated: true, completion:  {})
                }
            } else {
                let navController = UIStoryboard(name: "SetupRecurringDonation", bundle: nil).instantiateViewController(withIdentifier: "SetupRecurringDonationNavigationController") as! SetupRecurringDonationNavigationController
                context.navigationController?.pushViewController(navController, animated: true)
//                let overview = navController.children.first as! SetupRecurringDonationOverviewViewController
//                overview.reloadData = true
//                let detail = UIStoryboard(name: "SetupRecurringDonation", bundle: nil).instantiateViewController(withIdentifier: "RecurringDonationTurnsOverviewController") as! RecurringDonationTurnsOverviewController
//                detail.recurringDonationId = (request as! OpenRecurringRuleDetailFromNotificationRoute).recurringDonationId
//
//                navController.pushViewController(detail, animated: true)
            }
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is OpenRecurringRuleDetailFromNotificationRoute
    }
}
