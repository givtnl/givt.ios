//
//  AmountPresetsViewController.swift
//  ios
//
//  Created by Lennie Stockman on 31/08/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit

class AmountPresetsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var firstTextField: UITextField!
    @IBOutlet var secondTextField: UITextField!
    @IBOutlet var thirdTextField: UITextField!
    @IBAction func goBack(_ sender: Any) {
        self.backPressed(sender)
    }
    var ACCEPTABLE_CHARACTERS = "0123456789"
    var decimalNotation: String!

    @IBOutlet var save: CustomButton!
    @IBAction func save(_ sender: Any) {
        UserDefaults.standard.amountPresets = [firstTextField.text!.decimalValue,secondTextField.text!.decimalValue,thirdTextField.text!.decimalValue]
        self.backPressed(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "VOORKEURSBEDRAGEN"
        firstTextField.delegate = self
        decimalNotation = NSLocale.current.decimalSeparator! as String
        ACCEPTABLE_CHARACTERS.append(decimalNotation)
        firstTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        let amountPresets = UserDefaults.standard.amountPresets
        
        let fmt = NumberFormatter()
        fmt.minimumFractionDigits = 2
        
        firstTextField.text = fmt.string(from: amountPresets[0] as NSNumber)
        secondTextField.text = fmt.string(from: amountPresets[1] as NSNumber)
        thirdTextField.text = fmt.string(from: amountPresets[2] as NSNumber)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text!.decimalValue)
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered = string.components(separatedBy: cs).joined(separator: "")
        
        if textField.text == "0" && string == "0" {
            return false
        }
        
        if let commaPosition = textField.text!.index(of: ","), string != "" {
            if string == "," {
                return false
            }
            var splitString = textField.text!.split(separator: Character(decimalNotation))
            if splitString.count == 2 {
                if splitString[1].count == 2 {
                    return false
                }
            }
            
            
            
        }
        
        return (string == filtered)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
