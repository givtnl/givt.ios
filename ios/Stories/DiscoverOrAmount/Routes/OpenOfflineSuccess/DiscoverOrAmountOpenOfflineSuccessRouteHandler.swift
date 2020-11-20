//
//  OpenOfflineSuccessRouteHandler.swift
//  ios
//
//  Created by Maarten Vergouwe on 19/11/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class DiscoverOrAmountOpenOfflineSuccessRouteHandler : RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let request = request as! DiscoverOrAmountOpenOfflineSuccessRoute
        let vc = UIStoryboard.init(name: "DiscoverOrAmount", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: DiscoverOrAmountSuccessViewController.self)) as! DiscoverOrAmountSuccessViewController
        vc.subtitleText = "OfflineGegevenGivtMessageWithOrg".localized.replacingOccurrences(of: "{0}", with: request.collectGroupName)
        context.navigationController?.pushViewController(vc, animated: true)
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        request is DiscoverOrAmountOpenOfflineSuccessRoute
    }
}
