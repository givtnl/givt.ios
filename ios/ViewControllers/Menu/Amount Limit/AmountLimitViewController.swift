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
    @IBAction func goBack(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
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
        
        btnSave.isEnabled = value > 0
        btnSaveKeyboard?.isEnabled = value > 0
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
        
        amountLimit.returnKeyType = .done
        amountLimit.delegate = self
        amountLimit.tintColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        amountLimit.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        if UserDefaults.standard.amountLimit > 0 {
            amountLimit.text = String(UserDefaults.standard.amountLimit)
        }

        //createToolbar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }

    func createToolbar() {
        let btn = CustomButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.cornerRadius = 3
        btn.setBackgroundColor(color: UIColor.init(rgb: 0xE3E2E7), forState: .disabled)
        btn.highlightedBGColor = #colorLiteral(red: 0.1098039216, green: 0.662745098, blue: 0.4235294118, alpha: 1)
        btn.ogBGColor = #colorLiteral(red: 0.2549019608, green: 0.7882352941, blue: 0.5568627451, alpha: 1)
        btn.setTitle(btnSave.titleLabel?.text, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 18.0)
        btn.addTarget(self, action: #selector(save), for: .touchUpInside)
        btn.isUserInteractionEnabled = true
        btn.isEnabled = true
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(save))
        btn.gestureRecognizers?.append(tap)
        self.btnSaveKeyboard = btn
        
        let doneToolbar: UIToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: theScrollView.frame.width, height: 54)
        //doneToolbar.addSubview(btn)
        doneToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        doneToolbar.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        doneToolbar.clipsToBounds = true
        doneToolbar.barTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        doneToolbar.isUserInteractionEnabled = true

        let barItem = UIBarButtonItem(customView: btn)
        doneToolbar.setItems([barItem], animated: false)
        
        
        let customView = UIView()
        customView.frame = CGRect(x: 0, y: 0, width: theScrollView.frame.width, height: 64)
        
        customView.addSubview(btn)
        btn.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 20).isActive = true
        btn.bottomAnchor.constraint(equalTo: customView.bottomAnchor, constant: -10).isActive = true
        btn.trailingAnchor.constraint(equalTo: customView.trailingAnchor, constant: -20).isActive = true
        
        
        //amountLimit.inputAccessoryView = doneToolbar
        amountLimit.inputAccessoryView = customView
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
    
    @objc func keyboardDidShow(notification: NSNotification) {
//        theScrollView.contentInset.bottom -= 30
//        theScrollView.scrollIndicatorInsets.bottom -= 30
        

    }
    
    @IBOutlet var bottomSpaceConstraint: NSLayoutConstraint!
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            self.updateKeyboardConstraint(height: keyboardSize.height, duration: TimeInterval(duration))
        }
    }
    
    func updateKeyboardConstraint(height: CGFloat, duration: TimeInterval) {
        self.bottomSpaceConstraint.constant = height + 20
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            self.updateKeyboardConstraint(height: 0, duration: TimeInterval(duration))
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
            btnSave.isEnabled = true
            btnSaveKeyboard?.isEnabled = true
            let amountLimit: Int = Int(textField.text!)!
            textField.text = String(amountLimit)
            
            if (textField.text?.count)! >= 5 {
                textField.text = textField.text?.substring(0..<5)
                return
            }
        } else {
            textField.text = "0"
            btnSave.isEnabled = false
            btnSaveKeyboard?.isEnabled = false
            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
            return
        }
        
        
        
        
    }
    


}
