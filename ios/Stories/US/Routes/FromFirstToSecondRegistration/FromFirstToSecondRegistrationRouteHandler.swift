//
//  FromFirstToSecondRegistrationRouteHandler.swift
//  ios
//
//  Created by Mike Pattyn on 06/12/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class FromFirstToSecondRegistrationRouteHandler: RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let vc = UIStoryboard.init(name: "Registration", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: USSecondRegistrationViewController.self)) as! USSecondRegistrationViewController
        let route = (request as! FromFirstToSecondRegistrationRoute)
        vc.registerUserCommand = route.registerUserCommand
        vc.registerCreditCardByTokenCommand = route.registerCreditCardByTokenCommand
        context.navigationController?.pushViewController(vc, animated: true)
        
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is FromFirstToSecondRegistrationRoute
    }
}
