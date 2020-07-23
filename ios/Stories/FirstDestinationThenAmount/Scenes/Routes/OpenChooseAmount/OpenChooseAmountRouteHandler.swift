//
//  OpenChooseAmountSceneHandler.swift
//  ios
//
//  Created by Maarten Vergouwe on 17/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

public struct OpenChooseAmountRouteHandler : RequestHandlerWithContextProtocol {
    public func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let vc = UIStoryboard.init(name: "FirstDestinationThenAmount", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: ChooseAmountViewController.self)) as! ChooseAmountViewController
        vc.input = request as! OpenChooseAmountRoute
        context.navigationController?.pushViewController(vc, animated: true)
        try completion(() as! R.TResponse)
    }
    
    public func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is OpenChooseAmountRoute
    }
}
