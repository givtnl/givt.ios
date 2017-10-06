//
//  AmountLimitViewController.swift
//  ios
//
//  Created by Lennie Stockman on 30/08/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class AmountLimitViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var verticalConstraint: NSLayoutConstraint!
    @IBOutlet var topContstraint: NSLayoutConstraint!
    @IBOutlet var btnSave: CustomButton!
    @IBOutlet var amountLimit: UITextField!
    @IBOutlet var navBar: UINavigationBar!
    var isRegistration: Bool = false
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
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleTimer(timer: Timer) {
        addValue(positive: timer.userInfo as! Bool)
    }
    
    func addValue(positive: Bool) {
        var value: Int = Int(amountLimit.text!)!
        value += positive ? 5 : -5
        if value < 0 {
            value = 0
        }
        amountLimit.text = String(value)
        if (amountLimit.text?.characters.count)! >= 5 {
            amountLimit.text = amountLimit.text?.substring(0..<5)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isRegistration {
            btnSave.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
            /*for item in self.navBar.items! {
                item.leftBarButtonItem?.isEnabled = false
                item.leftBarButtonItem?.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
                //item.leftBarButtonItem?.
            }*/
           // self.backButton.setBackgroundImage(#imageLiteral(resourceName: "visible_eye.png"), for: .normal, barMetrics: .default)
            self.backButton.isEnabled = false
            self.backButton.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
           
        } else {
            btnSave.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        }
        
        
        
        amountLimit.returnKeyType = .done
        amountLimit.delegate = self
        amountLimit.tintColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        amountLimit.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        if UserDefaults.standard.amountLimit > 0 {
            amountLimit.text = String(UserDefaults.standard.amountLimit)
        }
    }
    
    @IBAction func btnSave(_ sender: UIButton) {
        LoginManager.shared.saveAmountLimit(Int(amountLimit.text!)!, completionHandler: {_,_ in
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
        NotificationCenter.default.addObserver(self, selector: #selector(AmountLimitViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AmountLimitViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
        
    func keyboardWillShow(notification: NSNotification) {
        //To retrieve keyboard size, uncomment following line
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
                bottomConstraint.constant = (keyboardSize?.height)! + 20
        verticalConstraint.constant = bottomConstraint.constant/2 * -1
        topContstraint.constant = bottomConstraint.constant/2 * -1

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //To retrieve keyboard size, uncomment following line
        //let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        bottomConstraint.constant = 20
        verticalConstraint.constant = 0
        topContstraint.constant = 0
    
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if (textField.text?.characters.count)! == 0 {
            textField.text = "0"
            return
        }
        
        let amountLimit: Int = Int(textField.text!)!
        textField.text = String(amountLimit)
        
        if (textField.text?.characters.count)! >= 5 {
            textField.text = textField.text?.substring(0..<5)
            return
        }
        
        
    }
    


}
