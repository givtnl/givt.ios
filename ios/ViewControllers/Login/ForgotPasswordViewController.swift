//
//  ForgotPasswordViewController.swift
//  ios
//
//  Created by Lennie Stockman on 12/12/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit
import SVProgressHUD

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {
    private var _appServices = AppServices.shared
    private var _navigationManager = NavigationManager.shared
    
    private var validationHelper = ValidationHelper.shared
    @IBOutlet var btnSend: CustomButton!
    @IBOutlet var emailField: CustomUITextField!
    @IBOutlet var headerText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        headerText.text = NSLocalizedString("ForgotPasswordText", comment: "")
        emailField.placeholder = NSLocalizedString("Email", comment: "")
        btnSend.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
        // Do any additional setup after loading the view.
        var email = ""
        if let userExt = UserDefaults.standard.userExt {
            email = userExt.email
        }
        
        emailField.text = email
        emailField.delegate = self
        checkAll()
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkAll), name: .UITextFieldTextDidChange, object: nil)
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var goBack: UIBarButtonItem!
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func send(_ sender: Any) {
        print("sending password forgot mail")
        if !_appServices.connectedToNetwork() {
            _navigationManager.presentAlertNoConnection(context: self)
            return
        }
        
        SVProgressHUD.show()
        LoginManager.shared.requestNewPassword(email: (emailField.text?.replacingOccurrences(of: " ", with: ""))!, callback: { (status) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            
            if let status = status {
                if status {
                    SVProgressHUD.showSuccess(withStatus: NSLocalizedString("CheckInbox", comment: ""))
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    if !self._appServices.connectedToNetwork() {
                        self._navigationManager.presentAlertNoConnection(context: self)
                        return
                    }
                    
                    let alert = UIAlertController(title: "", message: NSLocalizedString("SomethingWentWrong", comment: ""), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        
                    }))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: {
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                }
            } else {
                //response does not exist. ssl error?
                self._navigationManager.presentAlertNoConnection(context: self)
            }
        })
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.btnSend.isEnabled {
            send(btnSend)
        }
        self.view.endEditing(true)
        return false
    }
    
    @objc func checkAll() {
        let isEmailValid = validationHelper.isEmailAddressValid(self.emailField.text!)
        isEmailValid ? emailField.setValid() : emailField.setInvalid()
        self.btnSend.isEnabled = isEmailValid
        emailField.returnKeyType = isEmailValid ? .done : UIReturnKeyType.default
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
