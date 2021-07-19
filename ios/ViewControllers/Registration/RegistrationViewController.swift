//
//  RegistrationViewController.swift
//  ios
//
//  Created by Lennie Stockman on 22/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import SVProgressHUD
import AppCenterAnalytics
import Mixpanel

class RegistrationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var theScrollView: UIScrollView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet var forename: CustomUITextField!
    @IBOutlet var lastname: CustomUITextField!
    @IBOutlet var emailaddress: CustomUITextField!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var password: CustomUITextField!
    @IBOutlet var saveMyData: UILabel!
    @IBOutlet var switchButton: UIButton!
    @IBOutlet var passwordHint: UILabel!
    @IBOutlet var titleText: UILabel!
    private var _lastTextField: UITextField = UITextField()
    private var validationHelper = ValidationHelper.shared
    private var regDetailVC: RegistrationDetailViewController!

    private var _isShowingPassword = false
    
    var passwordField: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.topItem?.titleView = UIImageView(image: #imageLiteral(resourceName: "givt20h.png"))
        
        MSAnalytics.trackEvent("User started registration")
        Mixpanel.mainInstance().track(event: "User started registration")

        initButtonsWithTags()
        initTermsText()
        
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
        titleText.text = NSLocalizedString("RegisterPage", comment: "")
        forename.placeholder = NSLocalizedString("FirstName", comment: "")
        lastname.placeholder = NSLocalizedString("LastName", comment: "")
        emailaddress.placeholder = NSLocalizedString("Email", comment: "")
        password.placeholder = NSLocalizedString("Password", comment: "")
        passwordHint.text = NSLocalizedString("PasswordRule", comment: "")
        nextButton.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
        
        nextButton.setBackgroundColor(color: UIColor.init(rgb: 0xE3E2E7), forState: .disabled)
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)

        
        #if DEBUG
            forename.text = "Nico"
            lastname.text = "De Tester"
            emailaddress.text = "testen@givtapp.net"
            password.text = "Test123"
            switchButton.isSelected = true
            checkAll()
        #endif
        
        if let settings = UserDefaults.standard.userExt {
            emailaddress.text = settings.email
            emailaddress.isEnabled = false
        }
        
        if let passwordField = passwordField {
            password.text = passwordField
            password.isEnabled = false
            password.textColor = UIColor.gray
        }
        
        self.regDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "RegistrationDetailViewController") as! RegistrationDetailViewController
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        // prevents the scroll view from swallowing up the touch event of child buttons
        tapGesture.cancelsTouchesInView = false
        theScrollView.addGestureRecognizer(tapGesture)
        password.setRightPaddingPoints(40)
    }
    @IBAction func switchPasswordVisibility(_ sender: Any) {
        let button = sender as! UIButton
        button.isSelected = !button.isSelected
        password.isSecureTextEntry = !button.isSelected
    }
    
    @objc func openTerms() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
        vc.typeOfTerms = .privacyPolicy
        self.present(vc, animated: true, completion: {
            print("done terms")
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkAll), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func initButtonsWithTags() {
        forename.delegate = self
        forename.tag = 0
        lastname.delegate = self
        lastname.tag = 1
        emailaddress.delegate = self
        /* do not give emailadress a tag because we want to go from Lastname > Passwd because email will be blocked from entering input */
        password.delegate = self
        password.tag = 2
    }
    
    func initTermsText() {
        let attachment:NSTextAttachment = NSTextAttachment()
        attachment.image = #imageLiteral(resourceName: "littleinfo.png")
        attachment.bounds = CGRect(x: 0, y: -4, width: (attachment.image?.size.width)!, height: (attachment.image?.size.height)!)
        let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
        let myString:NSMutableAttributedString = NSMutableAttributedString(string: NSLocalizedString("AcceptPolicy", comment: "") + " ")
        myString.append(attachmentString)
        
        saveMyData.attributedText = myString
        let tap = UITapGestureRecognizer(target: self, action: #selector(openTerms))
        saveMyData.addGestureRecognizer(tap)
        saveMyData.isUserInteractionEnabled = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        _lastTextField = textField as! CustomUITextField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text! = textField.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        checkAll()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField.returnKeyType != .done {
            textField.resignFirstResponder()
            return false
        }
        
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false //prevents adding line break
    }
    
    @objc func checkAll() {
        let isNameValid = validationHelper.isBetweenCriteria(forename.text!, 32) && validationHelper.isValidName(forename.text!)
        let isLastNameValid = validationHelper.isBetweenCriteria(lastname.text!, 70) && validationHelper.isValidName(lastname.text!)
        let isEmailAddressValid = validationHelper.isEmailAddressValid(emailaddress.text!)
        let isPasswordValid = validationHelper.isPasswordValid(password.text!)
        let isChecked = switchButton.isSelected
        
        switch _lastTextField {
        case forename:
            isNameValid ? forename.setValid() : forename.setInvalid()
        case lastname:
            isLastNameValid ? lastname.setValid() : lastname.setInvalid()
        case emailaddress:
            isEmailAddressValid ? emailaddress.setValid() : emailaddress.setInvalid()
        case password:
            isPasswordValid ? password.setValid() : password.setInvalid()
        default:
            break
        }
        
        nextButton.isEnabled = isNameValid && isLastNameValid && isEmailAddressValid && isPasswordValid && isChecked
    }
    
    @IBAction func next(_ sender: Any) {
        let email = self.emailaddress.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let password = self.password.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let firstName = self.forename.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let lastName = self.lastname.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        self.regDetailVC.emailField = email
        self.regDetailVC.password = password
        self.regDetailVC.firstNameField = firstName
        self.regDetailVC.lastNameField = lastName
        self.show(self.regDetailVC, sender: nil)
    }

    @IBAction func switchCheckbox(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        _lastTextField = CustomUITextField() //clear hack
        checkAll()
    }

    @IBAction func exit(_ sender: Any) {
        self.endEditing()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        theScrollView.contentInset.bottom -= 20
        theScrollView.scrollIndicatorInsets.bottom -= 20
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            theScrollView.contentInset.bottom = contentInsets.bottom + 20
            theScrollView.scrollIndicatorInsets.bottom = contentInsets.bottom + 20
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            theScrollView.contentInset = .zero
            theScrollView.scrollIndicatorInsets = .zero
        }
    }
    
    @IBAction func openFAQ(_ sender: Any) {
        let vc = UIStoryboard(name: "FAQ", bundle: nil).instantiateInitialViewController() as! FAQViewController
        self.present(vc, animated: true, completion: nil)
    }
}

extension UIScrollView {
    
    // Scroll to a specific view so that it's top is at the top our scrollview
    func scrollToView(view:UIView, animated: Bool) {
        if let origin = view.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
            self.scrollRectToVisible(CGRect(x: 0, y: childStartPoint.y, width: 1, height: self.frame.height), animated: animated)
        }
    }
    
    // Bonus: Scroll to top
    func scrollToTop(animated: Bool) {
        let topOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(topOffset, animated: animated)
    }
    
    // Bonus: Scroll to bottom
    func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        if(bottomOffset.y > 0) {
            setContentOffset(bottomOffset, animated: true)
        }
    }
    
}
