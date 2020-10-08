//
//  GoToAboutViewRouteHandler.swift
//  ios
//
//  Created by Jonas Brabant on 08/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class GoToAboutViewRouteHandler: RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol
    {
        let vc = UIStoryboard.init(name: "AboutGivt", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: AboutViewController.self)) as! AboutViewController
        vc.prefilledText = NSLocalizedString("ReportMissingOrganisationPrefilledText", comment: "")
        context.navigationController?.pushViewController(vc, animated: true)
        
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is GoToAboutViewRoute
    }
}
