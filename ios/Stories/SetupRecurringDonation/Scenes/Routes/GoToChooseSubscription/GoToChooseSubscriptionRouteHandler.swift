//
//  GoToChooseSubscriptionRouteHandler.swift
//  ios
//
//  Created by Jonas Brabant on 28/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class GoToChooseSubscriptionRouteHandler : RequestHandlerWithContextProtocol {
   
    public func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        
            let vc = UIStoryboard.init(name: "SetupRecurringDonation", bundle: nil)
                .instantiateViewController(withIdentifier: String(describing: SetupRecurringDonationChooseSubscriptionViewController.self)) as! SetupRecurringDonationChooseSubscriptionViewController
            context.navigationController?.pushViewController(vc, animated: true)
            try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is GoToChooseSubscriptionRoute
    }
}




