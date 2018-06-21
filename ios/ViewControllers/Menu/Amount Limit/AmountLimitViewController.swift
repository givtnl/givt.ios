//
//  AmountLimitViewController.swift
//  ios
//
//  Created by Lennie Stockman on 30/08/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class AmountLimitViewController: UIViewController, UITextFieldDelegate {
    private let _appServices = AppServices.shared
    private let _navigationManager = NavigationManager.shared
    private let _loginManager = LoginManager.shared
    
    @IBOutlet var theScrollView: UIScrollView!
    @IBOutlet var subTitleText: UILabel!
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var btnSave: CustomButton!
    var btnSaveKeyboard: CustomButton?
    @IBOutlet var amountLimit: UITextField!
    var isRegistration: Bool = false
    var hasBackButton = false
    var timer: Timer?
    @IBAction func btnIncrease(_ sender: Any) {
        addValue(positive: true)
    }
    
    @IBAction func btnDecrease(_ sender: Any) {
        addValue(positive: false)
    }
    
    @IBAction func longPressIncrease(_ sender: UILongPressGestureRecognizer) {
        handlePress(sender, postive: true)
    }
    @IBAction func longPressDecrease(_ gesture: UILongPressGestureRecognizer) {
        handlePress(gesture, postive: false)
    }
    
    func handlePress(_ gesture: UILongPressGestureRecognizer, postive: Bool) {
        if gesture.state == .began {
            timer = Timer.scheduledTimer(timeInterval: 0.120, target: self, selector: #selector(handleTimer), userInfo: postive, repeats: true)
        } else if gesture.state == .ended || gesture.state == .cancelled {
            timer?.invalidate()
            timer = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    @objc func handleTimer(timer: Timer) {
        addValue(positive: timer.userInfo as! Bool)
    }
    
    func addValue(positive: Bool) {
        var value: Int = Int(amountLimit.text!)!
        value += positive ? 5 : -5
        if value < 0 {
            value = 0
        }
        amountLimit.text = String(value)
        if (amountLimit.text?.count)! >= 5 {
            amountLimit.text = amountLimit.text?.substring(0..<5)
        }
        
        btnSave.isEnabled = shouldEnableButton()
        btnSaveKeyboard?.isEnabled = shouldEnableButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subTitleText.text = NSLocalizedString("AmountLimit", comment: "")
        
        if hasBackButton {
            btnSave.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        } else {
            btnSave.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
            self.backButton.isEnabled = false
            self.backButton.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            self.backButton.image = UIImage()
        }
        
        btnSave.setBackgroundColor(color: UIColor.init(rgb: 0xE3E2E7), forState: .disabled)
        btnSave.isEnabled = false
        btnSave.accessibilityLabel = NSLocalizedString("Save", comment: "")
        
        amountLimit.returnKeyType = .done
        amountLimit.delegate = self
        amountLimit.tintColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        amountLimit.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        if UserDefaults.standard.amountLimit > 0 {
            amountLimit.text = String(UserDefaults.standard.amountLimit)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        // prevents the scroll view from swallowing up the touch event of child buttons
        tapGesture.cancelsTouchesInView = false
        theScrollView.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func btnSave(_ sender: UIButton) {
        save()
    }

    @objc func save() {
        self.view.endEditing(true)
        
        if !_appServices.connectedToNetwork() {
            _navigationManager.presentAlertNoConnection(context: self)
            return
        }
        
        _loginManager.saveAmountLimit(Int(amountLimit.text!)!, completionHandler: {_ in
            if self.isRegistration {
                DispatchQueue.main.async {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SPInfoViewController") as! SPInfoViewController
                    self.show(vc, sender: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.navigationController?.hideLeftView(nil)
                    self.dismiss(animated: true, completion: nil)
                }
            }

        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @IBOutlet var bottomSpaceConstraint: NSLayoutConstraint!
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            self.updateKeyboardConstraint(height: keyboardSize.height, duration: TimeInterval(truncating: duration))
        }
    }
    
    func updateKeyboardConstraint(height: CGFloat, duration: TimeInterval) {
        self.bottomSpaceConstraint.constant = height + 20
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            self.updateKeyboardConstraint(height: 0, duration: TimeInterval(truncating: duration))
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
    } 
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let amountLimit = Int(textField.text!), amountLimit > 0 {
            btnSave.isEnabled = shouldEnableButton()
            btnSaveKeyboard?.isEnabled = shouldEnableButton()
            let amountLimit: Int = Int(textField.text!)!
            textField.text = String(amountLimit)
            
            if (textField.text?.count)! >= 5 {
                textField.text = textField.text?.substring(0..<5)
                return
            }
        } else {
            textField.text = "0"
            btnSave.isEnabled = shouldEnableButton()
            btnSaveKeyboard?.isEnabled = shouldEnableButton()
            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
            return
        }
        
    }
    
    func shouldEnableButton() -> Bool {
        let limit = Int(amountLimit.text!)!
        return (limit > 0 && limit != UserDefaults.standard.amountLimit)
    }

}
