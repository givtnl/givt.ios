//
//  OpenExternalGivtsRouteHandler.swift
//  ios
//
//  Created by Mike Pattyn on 27/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import UIKit
import Foundation

class OpenExternalGivtsRouteHandler: RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let route = request as! OpenExternalGivtsRoute
        
        let vc = UIStoryboard.init(name: "Budget", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: BudgetExternalGivtsViewController.self)) as! BudgetExternalGivtsViewController
        vc.currentObjectInEditMode = route.id
        vc.externalDonations = route.externalDonations
        
        context.navigationController?.pushViewController(vc, animated: true)
        
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is OpenExternalGivtsRoute
    }
}
