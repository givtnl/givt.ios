//
//  NoInternetAlertHandler.swift
//  ios
//
//  Created by Maarten Vergouwe on 22/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class NoInternetAlertHandler : RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("ConnectionError", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
        }))
        context.present(alert, animated: true) {}
        try? completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is NoInternetAlert
    }
}
