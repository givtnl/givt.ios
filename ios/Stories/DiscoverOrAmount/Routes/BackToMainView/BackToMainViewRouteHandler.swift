//
//  BackToMainViewRouteHandler.swift
//  ios
//
//  Created by Mike Pattyn on 28/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class BackToMainViewRouteHandler : RequestHandlerWithContextProtocol {
   
    public func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        context.navigationController?.popToRootViewController(animated: true)
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is BackToMainViewRoute
    }
}
