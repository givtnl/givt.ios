//
//  LoginViewController.swift
//  ios
//
//  Created by Lennie Stockman on 07/08/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
   
    var completionHandler: () -> () = {}
    var string: String?
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet var backButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        txtUserName.placeholder = NSLocalizedString("Email", comment: "")
        txtPassword.placeholder = NSLocalizedString("Password", comment: "")
        txtTitle.text = NSLocalizedString("LoginText", comment: "")
        btnForgotPassword.setTitle(NSLocalizedString("ForgotPassword", comment: ""), for: .normal)
        btnLogin.setTitle(NSLocalizedString("Login", comment: ""), for: UIControlState.normal)
        txtUserName.delegate = self
        txtPassword.delegate = self
        print(string)
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
        login()
    }
    
    func showLoadingAnimation() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating();
        activityIndicator.hidesWhenStopped = true
        activityIndicator.tag = 1
        self.view.addSubview(activityIndicator)
        self.view.isUserInteractionEnabled = false
    }
    
    func login(){
        showLoadingAnimation()
        _ = LoginManager.shared.loginUser(email: txtUserName.text!,password: txtPassword.text!, completionHandler: { b, error in
            
                DispatchQueue.main.async {
                    if let viewWithTag = self.view.viewWithTag(1) {
                        self.view.isUserInteractionEnabled = true
                        viewWithTag.removeFromSuperview()
                    }
                }
                
            
            if b {
                print("logging user in")
                
                UserDefaults.standard.isLoggedIn = true
                DispatchQueue.main.async {
                    self.dismiss(animated: false, completion: { self.completionHandler() } )
                }
            } else {
                print("something wrong logging user in")
                let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""),
                                              message: NSLocalizedString("WrongCredentials", comment: ""),
                                              preferredStyle: UIAlertControllerStyle.alert)
                
                let cancelAction = UIAlertAction(title: "OK",
                                                 style: .cancel, handler: nil)
                
                alert.addAction(cancelAction)
                DispatchQueue.main.async(execute: {
                    self.present(alert, animated: true, completion: nil)
                })
            }
        })
    
    }
    @IBAction func switchPasswordVisibility(_ sender: Any) {
        let button = sender as! UIButton
        button.isSelected = !button.isSelected
        txtPassword.isSecureTextEntry = !button.isSelected
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
