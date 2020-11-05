//
//  OpenSetupRecurringDonationRouteHandler.swift
//  ios
//
//  Created by Mike Pattyn on 29/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class DiscoverOrAmountOpenSetupRecurringDonationRouteHandler: RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        NavigationManager.shared.executeWithLogin(context: context) {
            if !LoginManager.shared.isUserLoggedIn {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "SomethingWentWrong".localized, message: "Ti twa ni just", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    }))
                    context.present(alert, animated: true, completion:  {})
                }
            } else {
                let vc = UIStoryboard.init(name: "DiscoverOrAmount", bundle: nil)
                    .instantiateViewController(withIdentifier: String(describing: DiscoverOrAmountSetupRecurringDonationViewController.self)) as! DiscoverOrAmountSetupRecurringDonationViewController
                vc.input = (request as! DiscoverOrAmountOpenSetupRecurringDonationRoute)
                context.navigationController?.pushViewController(vc, animated: true)
            }
        }
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is DiscoverOrAmountOpenSetupRecurringDonationRoute
    }
}
