//
//  GoToPushNotificationRequestRouteHandler.swift
//  ios
//
//  Created by Bjorn Derudder on 16/09/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class GoToPushNotificationRequestRouteHandler: RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let vc = UIStoryboard.init(name: "SetupRecurringDonation", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: SetupNotificationRecurringDonationViewController.self)) as! SetupNotificationRecurringDonationViewController
        context.present(vc, animated: true)
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is GoToPushNotificationRequestRoute
    }
}
