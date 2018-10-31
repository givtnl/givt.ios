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
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet var btnSend: CustomButton!
    @IBOutlet var emailField: CustomUITextField!
    @IBOutlet var headerText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("ChangePassword", comment: "")
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
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
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 18)!, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)]
        self.navigationController?.removeLogo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var goBack: UIBarButtonItem!

    @IBAction func send(_ sender: Any) {
        print("sending password forgot mail")
        if !_appServices.isServerReachable {
            _navigationManager.presentAlertNoConnection(context: self)
            return
        }
        
        SVProgressHUD.show()
        LoginManager.shared.doesEmailExist(email: emailField.text!) { (status) in
            
            if status == "temp" {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                let alert = UIAlertController(title: NSLocalizedString("TemporaryAccount", comment: ""), message: NSLocalizedString("TempAccountLogin", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    NavigationHelper.showRegistration(context: self, email: self.emailField.text!)
                }))
                self.present(alert, animated: true, completion:  {})
            } else if status == "true" {
                LoginManager.shared.requestNewPassword(email: (self.emailField.text?.replacingOccurrences(of: " ", with: ""))!, callback: { (status) in
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                    }
                    
                    if let status = status {
                        if status {
                            let alert = UIAlertController(title: NSLocalizedString("Success", comment: ""), message: NSLocalizedString("ResetPasswordSent", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                                DispatchQueue.main.async {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }))
                            DispatchQueue.main.async {
                                self.present(alert, animated: true, completion: nil)
                            }
                        } else {
                            if !self._appServices.isServerReachable {
                                self._navigationManager.presentAlertNoConnection(context: self)
                                return
                            }
                            
                            let alert = UIAlertController(title: NSLocalizedString("RequestFailed", comment: ""), message: NSLocalizedString("NonExistingEmail", comment: ""), preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
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
            } else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                let alert = UIAlertController(title: NSLocalizedString("RequestFailed", comment: ""), message: NSLocalizedString("NonExistingEmail", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
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
