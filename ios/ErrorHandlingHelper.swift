//
//  ErrorHandlingHelper.swift
//  ios
//
//  Created by Maarten Vergouwe on 26/02/2019.
//  Copyright © 2019 Givt. All rights reserved.
//

import Foundation
import UIKit

class ErrorHandlingHelper {
    static func ShowLoginError(context: UIViewController, error: String) {
        var title = String("")
        var message = String("")
        switch error {
        case "NoInternet", "ServerError":
            title = NSLocalizedString("SomethingWentWrong", comment: "")
            message = NSLocalizedString("ConnectionError", comment: "")
        case "LockedOut":
            title = NSLocalizedString("TemporaryDisabled", comment: "")
            message = NSLocalizedString("WrongPasswordLockedOut", comment: "")
        case "WrongPassOrUser", "OneAttemptLeft", "TwoAttemptsLeft":
            title = NSLocalizedString("LoginFailure", comment: "")
            message = NSLocalizedString("WrongCredentials", comment: "")
        case "AccountDisabled":
            title = NSLocalizedString("LoginFailure", comment: "")
            message = NSLocalizedString("AccountDisabledError", comment: "")
        default:
            title = NSLocalizedString("SomethingWentWrong", comment: "")
            message = NSLocalizedString("ErrorContactGivt", comment: "")
        }
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        DispatchQueue.main.async(execute: {
            context.present(alert, animated: true, completion: nil)
        })
    }
}
