//
//  OpenYearlyOverviewDetailRouteHandler.swift
//  ios
//
//  Created by Mike Pattyn on 10/06/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class OpenYearlyOverviewRouteDetailHandler: RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let vc = UIStoryboard.init(name: "Budget", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: BudgetYearlyOverviewDetailViewController.self)) as! BudgetYearlyOverviewDetailViewController
        let route = (request as! OpenYearlyOverviewDetailRoute)
        vc.year = route.year
        vc.givtModels = route.givtModels
        vc.notGivtModels = route.notGivtModels
        context.navigationController?.pushViewController(vc, animated: true)
        
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is OpenYearlyOverviewDetailRoute
    }
}
