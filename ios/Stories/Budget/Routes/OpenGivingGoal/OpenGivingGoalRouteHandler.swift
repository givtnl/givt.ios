//
//  OpenGivingGoalRouteHandler.swift
//  ios
//
//  Created by Mike Pattyn on 04/05/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class OpenGivingGoalRouteHandler: RequestHandlerWithContextProtocol {
    private let slideFromRightAnimation = PresentFromRight()

    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
       
        let vc = UIStoryboard.init(name: "Budget", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: BudgetGivingGoalViewController.self)) as! BudgetGivingGoalViewController
        vc.transitioningDelegate = self.slideFromRightAnimation
        context.navigationController?.pushViewController(vc, animated: true)
        
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is OpenGivingGoalRoute
    }
}
