//
//  GoBackToYearlyOverviewRouteHandler.swift
//  ios
//
//  Created by Mike Pattyn on 14/06/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
class GoBackToYearlyOverviewRouteHandler: RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        (context.navigationController?.children.first(where: { vc in vc is BudgetYearlyOverviewViewController}) as! BudgetYearlyOverviewViewController).needsReload = (request as! GoBackToYearlyOverviewRoute).needsReload
        context.navigationController?.popViewController(animated: true)
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is GoBackToYearlyOverviewRoute
    }
}
