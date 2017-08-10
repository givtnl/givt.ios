//
//  LoginViewController.swift
//  ios
//
//  Created by Lennie Stockman on 07/08/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    let loginManager = LoginManager()
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        txtTitle.text = "Om toegang tot je account te krijgen, hoef je alleen even in te loggen."
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        txtPassword.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func performLogin(_ sender: UIButton) {
        btnLogin.loadingIndicator(show: true)
        loginManager.loginUser(email: txtUserName.text!,password: txtPassword.text!, completionHandler: { b, error in
            if let b = b {
                if(b){
                    print("logging user in")
                    UserDefaults.standard.isLoggedIn = true
                    UserDefaults.standard.synchronize()
                    self.dismiss(animated: true, completion: nil)
                } else {
                    DispatchQueue.main.async {
                        self.btnLogin.loadingIndicator(show: false)
                    }
                    print("something wrong logging user in")
                    DispatchQueue.main.async(execute: {
                        let alert = UIAlertController(title: "Oeps er gaat iets mis!",
                                                      message: "Je wachtwoord is onjuist.",
                                                      preferredStyle: UIAlertControllerStyle.alert)
                        
                        let cancelAction = UIAlertAction(title: "OK",
                                                         style: .cancel, handler: nil)
                        
                        alert.addAction(cancelAction)
                        self.present(alert, animated: true, completion: nil)
                    })
                    
                }
                
            } else {
                NSLog(String(describing: error))
            }
        })
        
        
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
