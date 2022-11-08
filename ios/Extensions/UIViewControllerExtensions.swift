//
//  UIViewControllerExtensions.swift
//  ios
//
//  Created by Lennie Stockman on 24/10/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

extension UIViewController {  
    @objc func endEditing() {
        self.view.endEditing(false)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        if self.isBeingPresented {
            self.dismiss(animated: true, completion: nil)
        } else {
            if self.navigationController?.viewControllers.count == 1 {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    func showLoader() {
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.native)
        SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.native)
        SVProgressHUD.show()
    }
    
    @objc func hideLoader() {
        SVProgressHUD.dismiss()
    }
    
    @objc func hideLoader(completion: @escaping () -> Void) {
        SVProgressHUD.dismiss(completion: completion)
    }
    
    func hideView(_ view: UIView, _ hide: Bool) {
        view.isHidden = hide
    }
    
    func showAlertWithConfirmation(title: String, message: String, completion: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: completion)
        alert.addAction(action)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
