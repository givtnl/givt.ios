//
//  ChangeAmountLimitRouteHandler.swift
//  ios
//
//  Created by Maarten Vergouwe on 22/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class ChangeAmountLimitRouteHandler : RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let request = request as! ChangeAmountLimitRoute
        
        LogService.shared.info(message: "User is opening giving limit")
        let transition = PresentFromRight()
        let vc = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "registration") as! RegNavigationController
        vc.startPoint = .amountLimit
        vc.isRegistration = request.shouldGoToRegistation
        vc.transitioningDelegate = transition
        vc.modalPresentationStyle = .fullScreen
        NavigationManager.shared.pushWithLogin(vc, context: context)
        
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is ChangeAmountLimitRoute
    }
}
