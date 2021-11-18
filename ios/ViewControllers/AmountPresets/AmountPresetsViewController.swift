//
//  AmountPresetsViewController.swift
//  ios
//
//  Created by Lennie Stockman on 31/08/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit
import AppCenterAnalytics
import Mixpanel
import LGSideMenuController

class AmountPresetsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var bodyText: UILabel!
    @IBOutlet var theScrollView: UIScrollView!
    @IBOutlet var firstTextField: AmountPresetUITextField!
    @IBOutlet var secondTextField: AmountPresetUITextField!
    @IBOutlet var thirdTextField: AmountPresetUITextField!
    @IBAction func goBack(_ sender: Any) {
        self.backPressed(sender)
    }
    var ACCEPTABLE_CHARACTERS = "0123456789"
    var decimalNotation: String!
    private var amountLimit = UserDefaults.standard.amountLimit
    private var fmt: NumberFormatter!
    @IBOutlet var save: CustomButton!
    @IBAction func save(_ sender: Any) {
        UserDefaults.standard.amountPresets =
            [self.getDecimalValue(text: firstTextField.text!)!,
             self.getDecimalValue(text: secondTextField.text!)!,
             self.getDecimalValue(text: thirdTextField.text!)!]
        LogService.shared.info(message: "Saving custom preset amounts")
        MSAnalytics.trackEvent("PRESET_CHANGE")
        Mixpanel.mainInstance().track(event: "PRESET_CHANGE")
        self.sideMenuController?.hideLeftView(sender: self)
        self.backPressed(self)
        NotificationCenter.default.post(name: .GivtDidSavePresets, object: nil)

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("AmountPresetsTitle", comment: "")
        bodyText.text = NSLocalizedString("AmountPresetsBody", comment: "")
        save.setTitle(NSLocalizedString("Save", comment: ""), for: UIControl.State.normal)
        
        firstTextField.delegate = self
        secondTextField.delegate = self
        thirdTextField.delegate = self
        let country = try? Mediater.shared.send(request: GetCountryQuery())
        let locale = Locale(identifier: "\(Locale.current.languageCode!)-\(country!)")
        decimalNotation = locale.decimalSeparator! as String
        ACCEPTABLE_CHARACTERS.append(decimalNotation)
        firstTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        secondTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        thirdTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let amountPresets = UserDefaults.standard.amountPresets
        
        fmt = NumberFormatter()
        fmt.minimumFractionDigits = 2
        fmt.minimumIntegerDigits = 1
        
        firstTextField.text = fmt.string(from: amountPresets[0] as NSNumber)
        secondTextField.text = fmt.string(from: amountPresets[1] as NSNumber)
        thirdTextField.text = fmt.string(from: amountPresets[2] as NSNumber)
        
        firstTextField.setLeftPaddingPoints(25)
        secondTextField.setLeftPaddingPoints(25)
        thirdTextField.setLeftPaddingPoints(25)
        
        firstTextField.setRightPaddingPoints(72)
        secondTextField.setRightPaddingPoints(72)
        thirdTextField.setRightPaddingPoints(72)
        
        
        save.setBackgroundColor(color: UIColor.init(rgb: 0xE3E2E7), forState: .disabled)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    
        checkAll()
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        // prevents the scroll view from swallowing up the touch event of child buttons
        tapGesture.cancelsTouchesInView = true
        theScrollView.addGestureRecognizer(tapGesture)
        
        createToolbar(firstTextField)
        createToolbar(secondTextField)
        createToolbar(thirdTextField)
    }
    func checkAll() {
        [firstTextField, secondTextField, thirdTextField].forEach { (tf) in
            if let value = getDecimalValue(text: tf!.text!) {
                tf!.text = fmt.string(from: value as NSNumber)
                let isBelowAmountLimit = value <= Decimal(amountLimit)
                let isHigherThan50Cent = value >= 0.25
                tf!.unfocus(isCorrect: isBelowAmountLimit && isHigherThan50Cent, note: !isBelowAmountLimit ? NSLocalizedString("AmountPresetsErrGivingLimit", comment: "") : NSLocalizedString("AmountPresetsErr25C", comment: ""))
            } else {
                tf!.unfocus(isCorrect: false, note: NSLocalizedString("AmountPresetsErrEmpty", comment: ""))
            }
        }
        save.isEnabled = firstTextField.isCorrect && secondTextField.isCorrect && thirdTextField.isCorrect
    }
    
    func createToolbar(_ textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(nextField(_:)))
        toolbar.setItems([spacer, done], animated: false)
        toolbar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolbar
    }
    
    @objc func nextField(_ barButtonItem: UIBarButtonItem) {
        if let tf = currentTextField {
            tf.resignFirstResponder()
        }
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        theScrollView.contentInset.bottom -= 20
        theScrollView.scrollIndicatorInsets.bottom -= 20
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            if #available(iOS 11.0, *) {
                theScrollView.contentInset.bottom = contentInsets.bottom + 20 - view.safeAreaInsets.bottom
                theScrollView.scrollIndicatorInsets.bottom = contentInsets.bottom + 20  - view.safeAreaInsets.bottom
            } else {
                theScrollView.contentInset.bottom = contentInsets.bottom + 20
                theScrollView.scrollIndicatorInsets.bottom = contentInsets.bottom + 20
            }
            
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            theScrollView.contentInset = .zero
            theScrollView.scrollIndicatorInsets = .zero
        }
    }
    var currentTextField: AmountPresetUITextField?
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
        if let tf = textField as? AmountPresetUITextField {
            currentTextField = tf
            if let value = getDecimalValue(text: tf.text!) {
                let isBelowAmountLimit = value <= Decimal(amountLimit)
                let isHigherThan25Cent = value >= 0.25
                tf.focus(isCorrect: isBelowAmountLimit && isHigherThan25Cent, note: !isBelowAmountLimit ? NSLocalizedString("AmountPresetsErrGivingLimit", comment: "") : NSLocalizedString("AmountPresetsErr25C", comment: ""))
            } else {
                tf.focus(isCorrect: false, note: NSLocalizedString("AmountPresetsErrEmpty", comment: ""))
            }
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let tf = textField as? AmountPresetUITextField {
            currentTextField = nil
            if let value = getDecimalValue(text: tf.text!) {
                tf.text = fmt.string(from: value as NSNumber)
                let isBelowAmountLimit = value <= Decimal(amountLimit)
                let isHigherThan25Cent = value >= 0.25
                tf.unfocus(isCorrect: isBelowAmountLimit && isHigherThan25Cent, note: !isBelowAmountLimit ? NSLocalizedString("AmountPresetsErrGivingLimit", comment: "") : NSLocalizedString("AmountPresetsErr25C", comment: ""))
            } else {
                tf.unfocus(isCorrect: false, note: NSLocalizedString("AmountPresetsErrEmpty", comment: ""))
            }
        }
    }
    
    func getDecimalValue(text: String) -> Decimal? {
        if text.contains(",") {
            return Decimal(string: text.replacingOccurrences(of: ",", with: "."))
        }
        if let value = Decimal(string: text) {
            return value
        }
        return nil
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let tf = textField as? AmountPresetUITextField {
            if let text = tf.text {
                if let value = getDecimalValue(text: text) {
                    let isBelowAmountLimit = value <= Decimal(amountLimit)
                    let isHigherThan25Cent = value >= 0.25
                    tf.focus(isCorrect: isBelowAmountLimit && isHigherThan25Cent, note: !isBelowAmountLimit ? NSLocalizedString("AmountPresetsErrGivingLimit", comment: "") : NSLocalizedString("AmountPresetsErr25C", comment: ""))
                } else {
                    tf.focus(isCorrect: false, note: NSLocalizedString("AmountPresetsErrEmpty", comment: ""))
                }
            } else {
                tf.focus(isCorrect: false, note: NSLocalizedString("AmountPresetsErrEmpty", comment: ""))
            }
            
        }
        save.isEnabled = firstTextField.isCorrect && secondTextField.isCorrect && thirdTextField.isCorrect
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered = string.components(separatedBy: cs).joined(separator: "")
        
        if textField.text == "0"  {
            if string == "0" {
                return false
            }
            if let decimal = Decimal(string: string), decimal > 0 {
                let startIndex = textField.text!.index(textField.text!.startIndex, offsetBy: 1)
                let endIndex = textField.text!.index(textField.text!.endIndex, offsetBy: 0)
                textField.text = String(textField.text![startIndex..<endIndex])
            }
        }
        
        if let commaPosition = textField.text!.index(of: decimalNotation), string != "" {
            if string == decimalNotation {
                return false
            }
            if range.location <= commaPosition.encodedOffset {
                return true
            }
            let splitString = textField.text!.split(separator: Character(decimalNotation))
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
}

class AmountPresetUITextField: UITextField {
    
    var borderView: UIView!
    var bar: UIView!
    var note: UILabel!
    var isCorrect = true

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 2
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        self.backgroundColor = UIColor.clear
        
        borderView = UIView()
        borderView.isUserInteractionEnabled = false
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = UIColor.white
        borderView.frame = self.bounds
        borderView.layer.cornerRadius = 3
        borderView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        borderView.layer.borderWidth = 1
        borderView.layer.masksToBounds = true
        self.addSubview(borderView)
        borderView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        borderView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        borderView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        borderView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        bar = UIView()
        bar.isUserInteractionEnabled = false
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.heightAnchor.constraint(equalToConstant: 5).isActive = true
        bar.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        borderView.addSubview(bar)
        bar.bottomAnchor.constraint(equalTo: borderView.bottomAnchor).isActive = true
        bar.leadingAnchor.constraint(equalTo: borderView.leadingAnchor).isActive = true
        bar.trailingAnchor.constraint(equalTo: borderView.trailingAnchor).isActive = true
        
        let img = UIImageView(image: #imageLiteral(resourceName: "pencil"))
        img.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(img)
        img.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        img.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        img.contentMode = .center
        img.widthAnchor.constraint(equalToConstant: 22).isActive = true
        img.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true
        img.isUserInteractionEnabled = false
        
        note = UILabel()
        note.translatesAutoresizingMaskIntoConstraints = false
        note.isUserInteractionEnabled = false
        note.font = UIFont(name: "Avenir-Light", size: 11)
        note.text = ""
        note.textColor = #colorLiteral(red: 0.7372586131, green: 0.09625744075, blue: 0.1143460795, alpha: 1)
        self.addSubview(note)
        note.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25).isActive = true
        note.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25).isActive = true
        note.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
    }
    
    func focus(isCorrect: Bool, note: String) {
        self.isCorrect = isCorrect
        if isCorrect {
            bar.backgroundColor = #colorLiteral(red: 0.1098039216, green: 0.662745098, blue: 0.4235294118, alpha: 1)
            borderView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            self.note.alpha = 0
        } else {
            bar.backgroundColor = #colorLiteral(red: 0.7372586131, green: 0.09625744075, blue: 0.1143460795, alpha: 1)
            borderView.layer.borderColor = #colorLiteral(red: 0.7372586131, green: 0.09625744075, blue: 0.1143460795, alpha: 1)
            self.note.alpha = 1
            self.note.text = note
        }
    }
    
    func unfocus(isCorrect: Bool, note: String) {
        self.isCorrect = isCorrect
        if isCorrect {
            bar.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            borderView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            self.note.alpha = 0
        } else {
            self.note.text = note
            self.note.alpha = 1
            bar.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            borderView.layer.borderColor = #colorLiteral(red: 0.7372586131, green: 0.09625744075, blue: 0.1143460795, alpha: 1)
        }
    }

}
