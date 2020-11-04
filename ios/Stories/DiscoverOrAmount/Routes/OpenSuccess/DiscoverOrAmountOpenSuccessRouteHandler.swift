//
//  DiscoverOrAmountOpenSuccessRouteHandler.swift
//  ios
//
//  Created by Mike Pattyn on 29/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class DiscoverOrAmountOpenSuccessRouteHandler: RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let vc = UIStoryboard.init(name: "DiscoverOrAmount", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: DiscoverOrAmountSuccessViewController.self)) as! DiscoverOrAmountSuccessViewController
        context.navigationController?.pushViewController(vc, animated: true)
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is DiscoverOrAmountOpenSuccessRoute
    }
}
