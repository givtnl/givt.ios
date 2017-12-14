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
    private var _navigationManager = NavigationManager.shared
    private var _appServices = AppServices.shared
    private var _loginManager = LoginManager.shared
    
    @IBOutlet var navBar: UINavigationItem!
    private var validationHelper = ValidationHelper.shared
    @IBOutlet var contentView: UIView!
    @IBOutlet var nextBtn: CustomButton!
    @IBOutlet var hintText: UILabel!
    @IBOutlet var subtitleText: UILabel!
    @IBOutlet var email: CustomUITextField!
    @IBOutlet var terms: UILabel!
    @IBOutlet var titleItem: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
 
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
        
        self.nextBtn.isEnabled = false
        
        #if DEBUG
            email.text = String.random() + "@givtapp.com"
            checkAll()
        #endif
        
        email.placeholder = NSLocalizedString("Email", comment: "")
        title = NSLocalizedString("EnterEmail", comment: "")
        subtitleText.text = NSLocalizedString("ToGiveWeNeedYourEmailAddress", comment: "")
        hintText.text = NSLocalizedString("WeWontSendAnySpam", comment: "")
        nextBtn.setTitle(NSLocalizedString("Continue", comment: ""), for: .normal)
        nextBtn.setBackgroundColor(color: UIColor.init(rgb: 0xE3E2E7), forState: .disabled)
        email.delegate = self

        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
    
        NotificationCenter.default.addObserver(self, selector: #selector(checkAll), name: .UITextFieldTextDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
 
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        
        // prevents the scroll view from swallowing up the touch event of child buttons
        tapGesture.cancelsTouchesInView = false
        
        scroll.addGestureRecognizer(tapGesture)
    
    }
    
    @objc func endEditing() {
        self.view.endEditing(false)
    }
    
    @IBOutlet var scroll: UIScrollView!
    
    @IBOutlet var container: UIView!
    @objc func keyboardDidShow(notification: NSNotification) {
        scroll.contentInset.bottom -= 20
        scroll.scrollIndicatorInsets.bottom -= 20
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
            scroll.contentInset.bottom = contentInsets.bottom + 20
            scroll.scrollIndicatorInsets.bottom = contentInsets.bottom + 20
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            scroll.contentInset = .zero
            scroll.scrollIndicatorInsets = .zero
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
        
        self.navigationController?.navigationBar.barTintColor = .white
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
    
    @IBAction func pop(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done(_ sender: Any) {
        doneCommand()
    }
    
    func doneCommand() {
        self.view.endEditing(true)

        if !_appServices.connectedToNetwork() {
            _navigationManager.presentAlertNoConnection(context: self)
            return
        }
        
        SVProgressHUD.show()
        _loginManager.doesEmailExist(email: email.text!) { (status) in
            
            if status == "true" { //completed registration
                self.openLogin()
            } else if status == "false" { //email is completely new
                self.registerTempUser()
            } else if status == "temp" { //email is in db but not succesfully registered
                self.openRegistration()
            } else {
                //strange response from server. internet connection err/ssl pin err
                self.hideLoader()
                self._navigationManager.presentAlertNoConnection(context: self)
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
            let ch: () -> Void = {
                self.navigationController?.dismiss(animated: false, completion: nil)
                self._navigationManager.loadMainPage()
            }
            vc.outerHandler = ch
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func openRegistration() {
        DispatchQueue.main.async {
            self.hideLoader()
            let userExt = UserDefaults.standard.userExt
            userExt?.email = self.email.text!
            UserDefaults.standard.userExt = userExt
            let register = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "registration") as! RegNavigationController
            self.present(register, animated: true, completion: nil)
        }
        
    }
    
    func registerTempUser() {
        _loginManager.checkTLD(email: self.email.text!, completionHandler: { (status) in
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
    
    func registerEmail(email: String) {
        _loginManager.registerEmailOnly(email: email, completionHandler: { (status) in
            self.hideLoader()
            if status {
                DispatchQueue.main.async {
                    self._navigationManager.loadMainPage()

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
