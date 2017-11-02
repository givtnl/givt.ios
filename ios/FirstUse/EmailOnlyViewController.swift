//
//  EmailOnlyViewController.swift
//  ios
//
//  Created by Lennie Stockman on 18/10/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import SVProgressHUD

class EmailOnlyViewController: UIViewController, UITextFieldDelegate {

    private var validationHelper = ValidationHelper.shared
    @IBOutlet var contentView: UIView!
    @IBOutlet var nextBtn: CustomButton!
    @IBOutlet var hintText: UILabel!
    @IBOutlet var subtitleText: UILabel!
    @IBOutlet var titleText: UILabel!
    @IBOutlet var email: CustomUITextField!
    @IBOutlet var terms: UILabel!
    @IBOutlet var titleItem: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
       navigationController?.setNavigationBarHidden(true, animated: false)

        
        let attachment:NSTextAttachment = NSTextAttachment()
        attachment.image = #imageLiteral(resourceName: "littleinfo.png")
        attachment.bounds = CGRect(x: 0, y: -4, width: (attachment.image?.size.width)!, height: (attachment.image?.size.height)!)
        let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
        let myString:NSMutableAttributedString = NSMutableAttributedString(string: NSLocalizedString("AcceptTerms", comment: "") + " ")
        myString.append(attachmentString)
        
        terms.attributedText = myString
        let tap = UITapGestureRecognizer(target: self, action: #selector(openTerms))
        terms.addGestureRecognizer(tap)
        terms.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
        
        #if DEBUG
            email.text = String.random() + "@givtapp.com"
            checkAll()
        #endif
        
        email.placeholder = NSLocalizedString("Email", comment: "")
        titleText.text = NSLocalizedString("EnterEmail", comment: "")
        subtitleText.text = NSLocalizedString("ToGiveWeNeedYourEmailAddress", comment: "")
        hintText.text = NSLocalizedString("WeWontSendAnySpam", comment: "")
        nextBtn.setTitle(NSLocalizedString("Continue", comment: ""), for: .normal)
        nextBtn.setBackgroundColor(color: UIColor.init(rgb: 0xE3E2E7), forState: .disabled)
        email.delegate = self
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkAll), name: .UITextFieldTextDidChange, object: nil)

    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print(self.view.frame.origin.y)
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done {
            self.doneCommand()
        }
        self.view.endEditing(true)
        return false
    }
    
    @objc func checkAll() {
        let isEmailValid = validationHelper.isEmailAddressValid(self.email.text!)
        isEmailValid ? email.setValid() : email.setInvalid()
        self.nextBtn.isEnabled = isEmailValid
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pop(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done(_ sender: Any) {
        doneCommand()
    }
    
    func doneCommand() {
        self.view.endEditing(true)
        SVProgressHUD.show()
        LoginManager.shared.doesEmailExist(email: email.text!) { (status) in
            
            if status == "true" {
                self.openLogin()
            } else if status == "false" {
                self.checkEmail()
            } else if status == "temp" {
                self.openRegistration()
            }
        }
    }
    
    func hideLoader() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
    
    @objc func openTerms() {
        let register = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
        register.typeOfTerms = .termsAndConditions
        self.present(register, animated: true, completion: nil)
    }
    
    func openLogin() {
        self.hideLoader()
        DispatchQueue.main.async {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ncLogin") as! LoginNavigationViewController
            let ch: () -> Void = { _ in
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
            vc.outerHandler = ch
            vc.email = self.email.text!
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func openRegistration() {
        self.hideLoader()
        let userExt = UserDefaults.standard.userExt
        userExt.email = email.text!
        UserDefaults.standard.userExt = userExt
        let register = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "registration") as! RegNavigationController
        self.present(register, animated: true, completion: nil)
    }
    
    func checkEmail() {
        LoginManager.shared.checkTLD(email: self.email.text!, completionHandler: { (status) in
            if status {
                self.registerEmail(email: self.email.text!)
            } else {
                self.hideLoader()
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong2", comment: ""), message: NSLocalizedString("ErrorTLDCheck", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    func registerEmail(email: String) {
        LoginManager.shared.registerEmailOnly(email: email, completionHandler: { (status) in
            self.hideLoader()
            if status {
                DispatchQueue.main.async {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            } else {
                //registration failed somehow...?
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("ErrorTextRegister", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }

}
