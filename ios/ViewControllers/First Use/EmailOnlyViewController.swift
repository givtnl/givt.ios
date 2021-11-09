//
//  EmailOnlyViewController.swift
//  ios
//
//  Created by Lennie Stockman on 18/10/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import SVProgressHUD

class EmailOnlyViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    let subtiel : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 17)!,
        NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.3513332009, green: 0.3270585537, blue: 0.5397221446, alpha: 1),
        NSAttributedString.Key.underlineStyle : 0]
    
    let focus : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 18)!,
        NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1),
        NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
    
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
            email.text = "givttest+"+String.random() + "@gmail.com"
            checkAll()
        #endif
        
        if let userExt = UserDefaults.standard.userExt, !userExt.email.isEmpty {
            email.text = userExt.email
            checkAll()
        }

        
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
    
        NotificationCenter.default.addObserver(self, selector: #selector(checkAll), name: UITextField.textDidChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
 
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        
        // prevents the scroll view from swallowing up the touch event of child buttons
        tapGesture.cancelsTouchesInView = false
        
        scroll.addGestureRecognizer(tapGesture)
        
        let attributedString = NSMutableAttributedString(string: NSLocalizedString("AlreadyAnAccount", comment: "") + " ", attributes: subtiel)
        attributedString.append(NSMutableAttributedString(string: NSLocalizedString("Login", comment: ""), attributes: focus))
        
        loginButton.setAttributedTitle(attributedString, for: UIControl.State.normal)
        
    #if DEBUG
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(hackFunctionForTesting(_:)))
        longPress.minimumPressDuration = 2
        longPress.delaysTouchesBegan = true
        longPress.delegate = self
        longPress.cancelsTouchesInView = false
        nextBtn.addGestureRecognizer(longPress)
    #endif
    }
    #if !PRODUCTION
    @objc func hackFunctionForTesting(_ sender: UILongPressGestureRecognizer) {
        UserDefaults.standard.hackForTesting = true
        let alert = UIAlertController(title: title,
                                      message: "Succesfully set CountryFromSim to US for testing.",
                                      preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    #endif
    func openLogin(emailEditable: Bool = false) {
        DispatchQueue.main.async {
            self.hideLoader()
            var config = UserExt()
            if let userExt = UserDefaults.standard.userExt {
                config = userExt
            }
            config.email = self.email.text!.trimmingCharacters(in: CharacterSet.init(charactersIn: " "))
            UserDefaults.standard.userExt = config
            NavigationManager.shared.executeWithLogin(context: self, emailEditable: emailEditable) {
                self.navigationController?.dismiss(animated: false, completion: nil)
                NavigationManager.shared.loadMainPage()
            }
        }
    }
    
    @IBAction func login(_ sender: Any) {
        openLogin(emailEditable: true)
    }
    
    @IBOutlet var scroll: UIScrollView!
    
    @IBOutlet var container: UIView!
    @objc func keyboardDidShow(notification: NSNotification) {
        scroll.contentInset.bottom -= 20
        scroll.scrollIndicatorInsets.bottom -= 20
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            scroll.contentInset.bottom = contentInsets.bottom + 20
            scroll.scrollIndicatorInsets.bottom = contentInsets.bottom + 20
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
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
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc func checkAll() {
        let isEmailValid = validationHelper.isEmailAddressValid(self.email.text!.trimmingCharacters(in: CharacterSet.init(charactersIn: " ")))
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

        let email = self.email.text!.trimmingCharacters(in: CharacterSet.init(charactersIn: " "))
        
        if !_appServices.isServerReachable {
            _navigationManager.presentAlertNoConnection(context: self)
            return
        }
        
        SVProgressHUD.show()
        _loginManager.doesEmailExist(email: email) { (status) in
            DispatchQueue.main.async {
                if status == "true" || status == "dashboard" { //show login if user completed registration or is a dashboard user TODO: rework!!
                    self.openLogin()
                } else if status == "false" { //email is completely new
                    self.registerTempUser()
                } else if status == "temp" { //email is in db but not succesfully registered
                    self.hideLoader()
                    NavigationHelper.showRegistration(context: self, email: email)
                } else {
                    //strange response from server. internet connection err/ssl pin err
                    self.hideLoader()
                    self._navigationManager.presentAlertNoConnection(context: self)
                }
            }
        }    
    }
    
    override func hideLoader() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
    
    @objc func openTerms() {
        let register = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
        register.typeOfTerms = .termsAndConditions
        self.present(register, animated: true, completion: nil)
    }
    
    func registerTempUser() {
        let email = self.email.text!.trimmingCharacters(in: CharacterSet.init(charactersIn: " "))
        _loginManager.checkTLD(email: email, completionHandler: { (status) in
            if status {
                self.registerEmail(email: email)
            } else {
                DispatchQueue.main.async {
                    self.hideLoader()
                    let alert = UIAlertController(title: NSLocalizedString("InvalidEmail", comment: ""), message: NSLocalizedString("ErrorTLDCheck", comment: ""), preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                        
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
                    let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("ErrorTextRegister", comment: ""), preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }

}
