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
    let subtiel : [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.font : UIFont(name: "Avenir-Light", size: 17)!,
        NSAttributedStringKey.foregroundColor : #colorLiteral(red: 0.3513332009, green: 0.3270585537, blue: 0.5397221446, alpha: 1),
        NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleNone.rawValue]
    
    let focus : [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.font : UIFont(name: "Avenir-Medium", size: 18)!,
        NSAttributedStringKey.foregroundColor : #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1),
        NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleNone.rawValue]
    
    private var _navigationManager = NavigationManager.shared
    private var _appServices = AppServices.shared
    private var _loginManager = LoginManager.shared
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var topNavigationBar: UINavigationBar!
    @IBOutlet var navBar: UINavigationItem!
    private var validationHelper = ValidationHelper.shared
    @IBOutlet var contentView: UIView!
    @IBOutlet var nextBtn: CustomButton!
    @IBOutlet var hintText: UILabel!
    @IBOutlet var subtitleText: UILabel!
    @IBOutlet var email: CustomUITextField!
    @IBOutlet var terms: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        topNavigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        topNavigationBar.shadowImage = UIImage()
        navBar.title = NSLocalizedString("WelcomeContinue", comment: "")
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
        
        topNavigationBar.items?.first?.leftBarButtonItems?.first?.accessibilityLabel = NSLocalizedString("Back", comment: "")
        
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
        
        let attributedString = NSMutableAttributedString(string: NSLocalizedString("AlreadyAnAccount", comment: "") + " ", attributes: subtiel)
        attributedString.append(NSMutableAttributedString(string: NSLocalizedString("Login", comment: ""), attributes: focus))
        
        loginButton.setAttributedTitle(attributedString, for: UIControlState.normal)
    
    }
    @IBAction func login(_ sender: Any) {
        DispatchQueue.main.async {
            var config = UserExt()
            if let userExt = UserDefaults.standard.userExt {
                config = userExt
            }
            config.email = self.email.text!
            UserDefaults.standard.userExt = config
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ncLogin") as! LoginNavigationViewController
            let ch: () -> Void = {
                self.navigationController?.dismiss(animated: false, completion: nil)
                NavigationManager.shared.loadMainPage()
            }
            vc.outerHandler = ch
            vc.emailEditable = true
            self.present(vc, animated: true, completion: nil)
        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.barTintColor = .white
        
        if let userExt = UserDefaults.standard.userExt, !userExt.email.isEmpty {
            email.text = userExt.email
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
            self._navigationManager.executeWithLogin(context: self) {
                self.navigationController?.dismiss(animated: false, completion: nil)
                self._navigationManager.loadMainPage()
            }
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
