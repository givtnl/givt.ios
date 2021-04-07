//
//  OpenGiveNowRouteHandler.swift
//  ios
//
//  Created by Mike Pattyn on 23/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class OpenGiveNowRouteHandler: RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        var validVc: AmountViewController? = nil
        if let lastVc = context.navigationController?.viewControllers.last,
            let lastVcIndex = context.navigationController?.viewControllers.lastIndex(of: lastVc),
            lastVcIndex > 0,
            let vc = context.navigationController?.viewControllers[lastVcIndex-1] as? AmountViewController {
            validVc = vc
            
        }
        
        if let vc = validVc {
            context.navigationController?.popToViewController(vc, animated: true)
        } else {
            context.dismiss(animated: true)
        }
        
        NotificationCenter.default.post(name: Notification.Name("GivtComingFromBudget"), object: nil)

        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is OpenGiveNowRoute
    }
}