//
//  USSecondRegistrationViewControllerPrivateExtension.swift
//  ios
//
//  Created by Mike Pattyn on 06/12/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import SVProgressHUD
import Algorithms

private extension USSecondRegistrationViewController {
    private func showRegistrationErrorAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "SomethingWentWrong".localized,
                message: "ErrorTextRegister".localized,
                preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
