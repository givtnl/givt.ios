//
//  RegistrationViewController.swift
//  ios
//
//  Created by Lennie Stockman on 22/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import SVProgressHUD

class RegistrationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var theScrollView: UIScrollView!
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
    override func viewDidLoad() {
        super.viewDidLoad()
        initButtonsWithTags()
        initTermsText()
        
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
        
        
        //emailaddress.color
        self.regDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "RegistrationDetailViewController") as! RegistrationDetailViewController
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkAll), name: .UITextFieldTextDidChange, object: nil)
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
        justifyScrollViewContent()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text! = textField.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
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
        let isNameValid = validationHelper.isBetweenCriteria(forename.text!, 32)
        let isLastNameValid = validationHelper.isBetweenCriteria(lastname.text!, 70)
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
        let email = self.emailaddress.text!
        let password = self.password.text!
        let firstName = self.forename.text!
        let lastName = self.lastname.text!
        SVProgressHUD.show()
        let user = RegistrationUser(email: email, password: password, firstName: firstName, lastName: lastName)
        LoginManager.shared.registerUser(user)
        SVProgressHUD.dismiss()
        //let regDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "SPWebViewController") as! SPWebViewController
        self.show(self.regDetailVC, sender: nil)
    }

    @IBAction func switchCheckbox(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        _lastTextField = CustomUITextField() //clear hack
        checkAll()
    }

    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func justifyScrollViewContent() {
        let bottomOffset = CGPoint(x: 0, y: (theScrollView.contentSize.height - theScrollView.bounds.size.height + theScrollView.contentInset.bottom));
        
        if _lastTextField.frame.minY < bottomOffset.y {
            theScrollView.setContentOffset(CGPoint(x: 0, y: _lastTextField.frame.minY), animated: true)
        } else {
            theScrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.theScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        theScrollView.contentInset = contentInset
        
        justifyScrollViewContent()
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        theScrollView.contentInset = contentInset
    }
    let slideAnimator = CustomPresentModalAnimation()
    @IBAction func openFAQ(_ sender: Any) {
        let vc = UIStoryboard(name: "FAQ", bundle: nil).instantiateInitialViewController() as! FAQViewController
        vc.transitioningDelegate = slideAnimator
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
