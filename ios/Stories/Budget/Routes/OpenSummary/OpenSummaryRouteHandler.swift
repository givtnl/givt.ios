//
//  OpenSummaryRouteHandler.swift
//  ios
//
//  Created by Mike Pattyn on 15/04/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class OpenSummaryRouteHandler: RequestHandlerWithContextProtocol {
    private let slideFromRightAnimation = PresentFromRight()

    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
       
        let vc = UIStoryboard(name: "Budget", bundle: nil).instantiateInitialViewController()
        vc?.modalPresentationStyle = .fullScreen
        vc?.transitioningDelegate = self.slideFromRightAnimation
        
        DispatchQueue.main.async {
            NavigationManager.shared.pushWithLogin(vc!, context: context)
        }
        
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is OpenSummaryRoute
    }
}
