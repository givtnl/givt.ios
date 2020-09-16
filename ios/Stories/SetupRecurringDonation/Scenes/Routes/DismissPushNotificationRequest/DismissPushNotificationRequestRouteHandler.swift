//
//  DismissPushNotificationRequestRouteHandler.swift
//  ios
//
//  Created by Bjorn Derudder on 17/09/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class DismissPushNotificationRequestRouteHandler: RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        context.dismiss(animated: true, completion: {})
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is DismissPushNotificationRequestRoute
    }
    
    
}
