//
//  OpenRecurringDonationOverviewListRouteHandler.swift
//  ios
//
//  Created by Mike Pattyn on 13/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class OpenRecurringDonationOverviewListRouteHandler: RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let vc = UIStoryboard.init(name: "SetupRecurringDonation", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: SetupRecurringDonationOverviewViewController.self)) as! SetupRecurringDonationOverviewViewController
        context.navigationController?.pushViewController(vc, animated: true)
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is OpenRecurringDonationOverviewListRoute
    }
}
