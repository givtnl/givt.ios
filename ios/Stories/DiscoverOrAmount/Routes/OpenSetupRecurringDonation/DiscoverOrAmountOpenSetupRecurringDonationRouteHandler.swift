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
        
        let transition = PresentFromRight()

        let vc = UIStoryboard.init(name: "DiscoverOrAmount", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: DiscoverOrAmountSetupRecurringDonationViewController.self)) as! DiscoverOrAmountSetupRecurringDonationViewController

        vc.input = (request as! DiscoverOrAmountOpenSetupRecurringDonationRoute)

        vc.transitioningDelegate = transition
        vc.modalPresentationStyle = .fullScreen
        NavigationManager.shared.pushWithLogin(vc, context: context)

        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is DiscoverOrAmountOpenSetupRecurringDonationRoute
    }
}
