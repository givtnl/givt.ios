//
//  BackToChooseDestinationRouteHandler.swift
//  ios
//
//  Created by Mike Pattyn on 27/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class SetupRecurringDonationChooseDestinationRouteHandler: RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let vc = UIStoryboard.init(name: "SetupRecurringDonation", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: SetupRecurringDonationChooseDestinationViewController.self)) as! SetupRecurringDonationChooseDestinationViewController
        context.navigationController?.pushViewController(vc, animated: true)
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is SetupRecurringDonationChooseDestinationRoute
    }
}
