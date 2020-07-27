//
//  OpenChooseAmountRouteHandler.swift
//  ios
//
//  Created by Mike Pattyn on 27/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

public struct SetupRecurringDonationOpenChooseAmountRouteHandler : RequestHandlerWithContextProtocol {
    public func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let vc = UIStoryboard.init(name: "SetupRecurringDonation", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: SetupRecurringDonationChooseAmountViewController.self)) as! SetupRecurringDonationChooseAmountViewController
        vc.input = request as! SetupRecurringDonationOpenChooseAmountRoute
        context.navigationController?.pushViewController(vc, animated: true)
        try completion(() as! R.TResponse)
    }
    
    public func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is SetupRecurringDonationOpenChooseAmountRoute
    }
}
