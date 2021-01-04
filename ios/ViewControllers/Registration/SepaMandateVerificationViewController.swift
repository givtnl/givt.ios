//
//  SepaMandateVerificationViewController.swift
//  ios
//
//  Created by Bjorn Derudder on 04/01/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class SepaMandateVerificationViewController: UIViewController {
    
    private var _navigationManager = NavigationManager.shared
    private var _appServices = AppServices.shared
    private var _loginManager = LoginManager.shared
    private var log = LogService.shared
        
    @IBOutlet weak var btnNext: CustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnNext.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
    }
    
    @IBAction func SignMandate(_ sender: Any) {
        if !_appServices.isServerReachable {
            _navigationManager.presentAlertNoConnection(context: self)
            return
        }
        
        NavigationManager.shared.reAuthenticateIfNeeded(context: self) {
            SVProgressHUD.show()
            self._loginManager.registerMandate(completionHandler: { (response) in
                SVProgressHUD.dismiss()
                var hasError = true
                if let r = response, r.basicStatus == .ok {
                    
                    if (r.basicStatus == .ok) {
                        hasError = false
                        self.log.info(message: "Mandate flow will now start")
                        DispatchQueue.main.async {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "FinalRegistrationViewController") as! FinalRegistrationViewController
                            self.show(vc, sender: nil)
                        }
                    }
                    
                    if hasError {
                        let alert = UIAlertController(title: NSLocalizedString("RequestFailed", comment: ""), message: NSLocalizedString("RequestMandateFailed", comment: ""), preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            NavigationManager.shared.loadMainPage()
                            self.dismiss(animated: true, completion: {})
                        }))
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: {})
                        }
                    }
                }})
        }
    }
}
