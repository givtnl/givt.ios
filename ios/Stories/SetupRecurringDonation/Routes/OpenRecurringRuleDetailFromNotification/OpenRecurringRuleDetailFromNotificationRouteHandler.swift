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
            SVProgressHUD.dismiss()
            if !LoginManager.shared.isUserLoggedIn {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "SomethingWentWrong".localized, message: "Ti twa ni just", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    }))
                    context.present(alert, animated: true, completion:  {})
                }
            } else {
                let recurringDonationNav = UIStoryboard(name:"SetupRecurringDonation", bundle: nil).instantiateInitialViewController() as! SetupRecurringDonationNavigationController
                let overview = UIStoryboard(name: "SetupRecurringDonation", bundle: nil).instantiateViewController(withIdentifier: String(describing: SetupRecurringDonationOverviewViewController.self)) as! SetupRecurringDonationOverviewViewController
                let detail = UIStoryboard(name: "SetupRecurringDonation", bundle: nil).instantiateViewController(withIdentifier: String(describing: RecurringDonationTurnsOverviewController.self)) as! RecurringDonationTurnsOverviewController
                detail.recurringDonationId = (request as! OpenRecurringRuleDetailFromNotificationRoute).recurringDonationId
                detail.comingFromNotification = true
                recurringDonationNav.modalPresentationStyle = .fullScreen
                recurringDonationNav.viewControllers = [overview, detail]
                DispatchQueue.main.async {
                    context.present(recurringDonationNav, animated: false, completion: nil)
                }
            }
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is OpenRecurringRuleDetailFromNotificationRoute
    }
}
