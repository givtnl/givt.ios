//
//  ChangeSettingViewController.swift
//  ios
//
//  Created by Lennie Stockman on 19/06/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit

class ChangeSettingViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var saveBtn: CustomButton!
    @IBOutlet var bottomAnchor: NSLayoutConstraint!
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var inputFieldToEdit: SpecialUITextField!
    @IBOutlet var fieldToEdit: UILabel!
    var saveAction: () -> Void = {}
    var validateFunction: (String) -> Bool = {_ in return false}
    var titleOfInput: String!
    var inputOfInput: String!
    var img: UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:Notification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: Notification.Name.UITextFieldTextDidChange, object: nil)
        
        inputFieldToEdit.text = inputOfInput
        fieldToEdit.text = titleOfInput
        imgView.image = img
        
        inputFieldToEdit.delegate = self
        inputFieldToEdit.becomeFirstResponder()
        inputFieldToEdit.beganEditing()
        
        saveBtn.setBackgroundColor(color: #colorLiteral(red: 0.8232886195, green: 0.8198277354, blue: 0.8529217839, alpha: 1), forState: .disabled)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        inputFieldToEdit.isValid = validateFunction(textField.text!)
        saveBtn.isEnabled = inputFieldToEdit.isValid
    }
    
    @objc func textFieldDidChange() {
        inputFieldToEdit.isValid = validateFunction(inputFieldToEdit.text!)
        saveBtn.isEnabled = inputFieldToEdit.isValid
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UITextFieldTextDidChange, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveAction(_ sender: Any) {
        self.saveAction()
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //and then:
    //MARK: Animate Keyboard
    @objc func keyboardWillShow(notification : NSNotification){
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            animateKeyboard(withConstraintValue: keyboardSize.size.height + 20)
        }
    }
    
    @objc func keyboardWillHide(notification : NSNotification){
        
        animateKeyboard(withConstraintValue: 20)
    }
    
    func animateKeyboard(withConstraintValue: CGFloat){
        
        bottomAnchor.constant = withConstraintValue
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.view.layoutIfNeeded()
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
