//
//  BackToChooseDestinationHandler.swift
//  ios
//
//  Created by Maarten Vergouwe on 21/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class BackToChooseDestinationRouteHandler: RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        context.navigationController?.popViewController(animated: true)
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is BackToChooseDestinationRoute
    }
}
