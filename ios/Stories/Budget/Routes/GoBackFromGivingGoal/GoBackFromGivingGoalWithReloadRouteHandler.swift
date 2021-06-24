//
//  GoBackFromGivingGoalWithReloadRouteHandler.swift
//  ios
//
//  Created by Mike Pattyn on 23/06/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class GoBackFromGivingGoalWithReloadRouteHandler: RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        guard let givingGoalVc: BudgetGivingGoalViewController = context as? BudgetGivingGoalViewController else {
            return try completion(() as! R.TResponse)
        }
        
        let vcIndex: Int = givingGoalVc.navigationController?.children.firstIndex(of: givingGoalVc) ?? 1
        let comingFromVc = givingGoalVc.navigationController?.children[vcIndex-1]
        
        switch(comingFromVc) {
        case is BudgetOverviewViewController:
            (comingFromVc as! BudgetOverviewViewController).needsReload = (request as! GoBackFromGivingGoalWithReloadRoute).needsReload
            break;
        case is BudgetYearlyOverviewViewController:
            (comingFromVc as! BudgetYearlyOverviewViewController).needsReload = (request as! GoBackFromGivingGoalWithReloadRoute).needsReload
            break;
        default: break;
        }
        context.navigationController?.popViewController(animated: true)
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is GoBackFromGivingGoalWithReloadRoute
    }
}
