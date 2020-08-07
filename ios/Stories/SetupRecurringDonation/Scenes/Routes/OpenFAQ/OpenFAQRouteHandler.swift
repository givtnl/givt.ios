//
//  OpenFAQRouteHandler.swift
//  ios
//
//  Created by Mike Pattyn on 06/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//
import Foundation
import UIKit

class OpenFAQRouteHandler : RequestHandlerWithContextProtocol {
    public func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let vc = UIStoryboard.init(name: "FAQ", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: FAQViewController.self)) as! FAQViewController
        vc.input = request as! OpenFAQRoute
        context.navigationController?.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        context.navigationController?.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        context.present(vc, animated: true)

        try completion(() as! R.TResponse)
    }
    
    public func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is OpenFAQRoute
    }
}
