//
//  LoginViewController.swift
//  ios
//
//  Created by Lennie Stockman on 07/08/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import SVProgressHUD

class LoginViewController: UIViewController, UITextFieldDelegate {
    private let _appServices = AppServices.shared
    private let _navigationManager = NavigationManager.shared
    
    var completionHandler: () -> () = {}
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var backButton: UIBarButtonItem!
    var emailEditable: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
        txtUserName.placeholder = NSLocalizedString("Email", comment: "")
        txtPassword.placeholder = NSLocalizedString("Password", comment: "")
        txtTitle.text = NSLocalizedString("LoginText", comment: "")
        btnForgotPassword.setTitle(NSLocalizedString("ForgotPassword", comment: ""), for: .normal)
        btnLogin.setTitle(NSLocalizedString("Login", comment: ""), for: UIControlState.normal)
        txtUserName.delegate = self
        txtPassword.delegate = self
        var email = ""
        if let userExt = UserDefaults.standard.userExt {
            email = userExt.email
        }
        title = NSLocalizedString("Login", comment: "")
 
        txtUserName.text = email
        if !email.isEmpty() && !emailEditable {
            txtUserName.isEnabled = false
            txtUserName.textColor = #colorLiteral(red: 0.537254902, green: 0.537254902, blue: 0.537254902, alpha: 1)
            txtPassword.becomeFirstResponder()
        }
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case txtUserName:
            txtPassword.becomeFirstResponder()
        case txtPassword:
            textField.resignFirstResponder()
            login()
        default: break
        }
        
        return false
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.endEditing()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        //To retrieve keyboard size, uncomment following line
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        bottomConstraint.constant = (keyboardSize?.height)! + 20
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        //To retrieve keyboard size, uncomment following line
        //let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        bottomConstraint.constant = 20
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func performLogin(_ sender: UIButton) {
        self.endEditing()
        login()
    }
    
    func login(){
        if !_appServices.connectedToNetwork() {
            _navigationManager.presentAlertNoConnection(context: self)
            return
        }
        
        SVProgressHUD.show()
        LoginManager.shared.doesEmailExist(email: txtUserName.text!) { (status) in
            if status == "temp" { //email is in db but not succesfully registered
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                let alert = UIAlertController(title: NSLocalizedString("Givt", comment: ""), message: NSLocalizedString("TempAccountLogin", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    NavigationHelper.showRegistration(context: self, email: self.txtUserName.text!)
                }))
                self.present(alert, animated: true, completion:  {})
            } else if status == "dashboard" {
                self.doLogin() { res in
                    if res {
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                        }
                        print("Logging dashboard user in" )
                        NavigationHelper.showRegistration(context: self, email: self.txtUserName.text!, password: self.txtPassword.text!)
                    }
                }
            } else {
                self.doLogin() { res in
                    if res {
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                        }
                        print("logging user in")
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: { self.completionHandler() } )
                        }
                    }
                }
            }
        }
    }
    
    func doLogin(completion: @escaping (Bool) -> Void) {
        _ = LoginManager.shared.loginUser(email: self.txtUserName.text!,password: self.txtPassword.text!, type: .password, completionHandler: { b, error, description in
            if b {
                completion(true)
            } else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                print("something wrong logging user in")
                var message = NSLocalizedString("WrongCredentials", comment: "")
                if description == "NoInternet" {
                    message = NSLocalizedString("ConnectionError", comment: "")
                } else if description == "ServerError" {
                    message = NSLocalizedString("ConnectionError", comment: "")
                } else if description == "LockedOut" {
                    message = NSLocalizedString("WrongPasswordLockedOut", comment: "")
                }
                
                let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""),
                                              message: message,
                                              preferredStyle: UIAlertControllerStyle.alert)
                
                let cancelAction = UIAlertAction(title: "OK",
                                                 style: .cancel, handler: nil)
                
                alert.addAction(cancelAction)
                DispatchQueue.main.async(execute: {
                    self.present(alert, animated: true, completion: nil)
                })
                completion(false)
            }
        })
    }
    
    @IBAction func switchPasswordVisibility(_ sender: Any) {
        let button = sender as! UIButton
        button.isSelected = !button.isSelected
        txtPassword.isSecureTextEntry = !button.isSelected
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
        
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
