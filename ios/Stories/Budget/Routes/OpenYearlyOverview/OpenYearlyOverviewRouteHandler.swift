//
//  OpenYearlyOverviewRouteHandler.swift
//  ios
//
//  Created by Mike Pattyn on 04/06/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class OpenYearlyOverviewRouteHandler: RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let route = (request as! OpenYearlyOverviewRoute)
        
        let vc = UIStoryboard.init(name: "Budget", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: BudgetYearlyOverviewViewController.self)) as! BudgetYearlyOverviewViewController
        vc.collectGroupsForCurrentMonth = route.collectGroupsForCurrentMonth
        vc.notGivtModelsForCurrentMonth = route.notGivtModelsForCurrentMonth
        
        context.navigationController?.pushViewController(vc, animated: true)
        
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is OpenYearlyOverviewRoute
    }
}
