//
//  GoBackToSummaryRouteHandler.swift
//  ios
//
//  Created by Mike Pattyn on 01/06/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class GoBackToSummaryRouteHandler: RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        (context.navigationController?.children[0] as! BudgetOverviewViewController).needsReload = (request as! GoBackToSummaryRoute).needsReload
        context.navigationController?.popViewController(animated: true)
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is GoBackToSummaryRoute
    }
}
