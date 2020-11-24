//
//  ShowUpdateAlertHandler.swift
//  ios
//
//  Created by Mike Pattyn on 24/11/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class ShowUpdateAlertHandler : RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let alert = UIAlertController(title: "UpdateAlertTitle".localized, message: "UpdateAlertMessage".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: { (action) in
            
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            DispatchQueue.main.async {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: AppConstants.appStoreUrl)!, options: [:], completionHandler: { (status) in
                        print(status)
                    })
                } else {
                    UIApplication.shared.openURL(URL(string: AppConstants.appStoreUrl)!)
                }
            }
        }))
        context.present(alert, animated: true) {}
        try? completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is ShowUpdateAlert
    }
}
