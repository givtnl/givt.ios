//
//  PersonalInfoViewController.swift
//  ios
//
//  Created by Lennie Stockman on 30/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit
import SVProgressHUD
import MaterialComponents

class PersonalInfoViewController: UIViewController, UITextFieldDelegate {
    private let loginManager = LoginManager.shared
    private let validationHelper = ValidationHelper.shared
    @IBOutlet var btnNext: CustomButton!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet var titleText: UILabel!
    @IBOutlet var settingsTableView: UITableView!
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.returnKeyType == .done {
            self.endEditing()
            save()
        }
        return false
    }
    @IBAction func next(_ sender: Any) {
        self.endEditing()
        save()
    }
    
    func save() {
        if let userExt = UserDefaults.standard.userExt, userExt.iban == ibanInput.text!.replacingOccurrences(of: " ", with: "") {
            self.dismiss(animated: true, completion: nil)
            print("trying to save iban that did not change")
            return
        }
        SVProgressHUD.show()
        loginManager.changeIban(iban: ibanInput.text!.replacingOccurrences(of: " ", with: "")) { (success) in
            SVProgressHUD.dismiss()
            if success {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("UpdatePersonalInfoError", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                }))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let iban = textField as? SpecialUITextField, iban == ibanInput {
            if let i = iban.text {
                iban.isValid = validationHelper.isIbanChecksumValid(i)
                btnNext.isEnabled = iban.isValid
            }
            
            textField.text = textField.text?.replacingOccurrences(of: " ", with: "").separate(every: 4, with: " ")
            if let pos = self.position {
                if deleting {
                    //set cursor
                    if let newPosition = textField.position(from: textField.beginningOfDocument, offset: pos-1) {
                        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                    }
                    
                    if let cursorRange = textField.selectedTextRange, let newPosition = textField.position(from: cursorRange.start, offset: 1) {
                        let range = textField.textRange(from: newPosition, to: cursorRange.start)
                        //when deleting a space, remove the number before the space too.
                        if textField.text(in: range!) == " " {
                            //remove the number at the specific location
                            textField.text?.remove(at: (textField.text?.index((textField.text?.startIndex)!, offsetBy: textField.offset(from: textField.beginningOfDocument, to: textField.position(from: cursorRange.start, offset: -1)!)))!)
                            
                            //reformat
                            textField.text = textField.text?.replacingOccurrences(of: " ", with: "").separate(every: 4, with: " ")
                            
                            //put pointer back
                            textField.selectedTextRange = textField.textRange(from: textField.position(from: cursorRange.start, offset: -1)!, to: textField.position(from: cursorRange.start, offset: -1)!)
                        }
                    }
                } else {
                    //set cursor
                    if let newPosition = textField.position(from: textField.beginningOfDocument, offset: pos+1) {
                        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                    }
                    
                    //set position when editing existing IBAN.
                    if let cursorRange = textField.selectedTextRange, let newPosition = textField.position(from: cursorRange.start, offset: -1) {
                        // get the position one character before the cursor start position
                        let range = textField.textRange(from: newPosition, to: cursorRange.start)
                        if textField.text(in: range!) == " " {
                            if let fixPosition = textField.position(from: newPosition, offset: 2) {
                                textField.selectedTextRange = textField.textRange(from: fixPosition, to: fixPosition)
                            }
                        }
                    }
                }
            }
            
        } else if let tf = textField as? SpecialUITextField, tf == emailInput {
            print("is email")
            tf.isValid = validationHelper.isEmailAddressValid(tf.text!)
        }
    }
    
    @IBOutlet var changePassword: UIView!
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let tf = textField as? SpecialUITextField {
            tf.beganEditing()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let tf = textField as? SpecialUITextField {
            tf.endedEditing()       
        }
    }
    
    private var position: Int?
    private var deleting: Bool = false
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let selectedRange = textField.selectedTextRange {
            self.deleting = false
            if range.length == 1 {
                deleting = true
            }
            
            let cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
            position = cursorPosition
        }
        return true
    }
    
    @IBOutlet var theScrollView: UIScrollView!
    @objc func keyboardDidShow(notification: NSNotification) {
        theScrollView.contentInset.bottom -= 20
        theScrollView.scrollIndicatorInsets.bottom -= 20
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
            theScrollView.contentInset.bottom = contentInsets.bottom + 20
            theScrollView.scrollIndicatorInsets.bottom = contentInsets.bottom + 20
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            theScrollView.contentInset = .zero
            theScrollView.scrollIndicatorInsets = .zero
        }
    }

    @IBOutlet var emailInput: SpecialUITextField!
    @IBOutlet var ibanInput: SpecialUITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settings = [PersonalSetting]()
        settingsTableView.tableFooterView = UIView()
        
        self.navigationController?.removeLogo()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
       
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
        
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
       // titleText.text = NSLocalizedString("PersonalPageHeader", comment: "") + "\n\n" + NSLocalizedString("PersonalPageSubHeader", comment: "")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let user = UserDefaults.standard.userExt!
        var country = ""
        if let idx = Int(user.countryCode) {
            country = AppConstants.countries[idx].name
        } else {
            country = AppConstants.countries.first(where: { $0.shortName == user.countryCode })!.name
        }
        title = NSLocalizedString("TitlePersonalInfo", comment: "")
        settings.removeAll()
        settings.append(PersonalSetting(image: #imageLiteral(resourceName: "personal_gray"), name: user.firstName + " " + user.lastName, type: .name))
        settings.append(PersonalSetting(image: #imageLiteral(resourceName: "email_sign"), name: user.email, type: .emailaddress))
        settings.append(PersonalSetting(image: #imageLiteral(resourceName: "house"), name: user.address, type: .address))
        settings.append(PersonalSetting(image: #imageLiteral(resourceName: "location"), name: user.postalCode + " " + user.city + ", " + country, type: .countrycode))
        settings.append(PersonalSetting(image: #imageLiteral(resourceName: "phone"), name: user.mobileNumber, type: .phonenumber))
        settings.append(PersonalSetting(image: #imageLiteral(resourceName: "card"), name: user.iban, type: .iban))
        settings.append(PersonalSetting(image: #imageLiteral(resourceName: "green_lock"), name: NSLocalizedString("ChangePassword", comment: ""), type: PersonalInfoViewController.SettingType.changepassword))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.endEditing()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func changePassword2() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "ForgotPassword", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        self.show(newViewController, sender: nil)
    }
    
    @IBAction func goLostPassword(_ sender: Any) {
        changePassword2()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let selectedRow = settingsTableView.indexPathForSelectedRow {
            settingsTableView.deselectRow(at: selectedRow, animated: false)
        }
    }
    
    var settings: [PersonalSetting]!
    
    struct PersonalSetting {
        var image: UIImage
        var name: String
        var type: SettingType
    }
    enum SettingType {
        case name
        case emailaddress
        case address
        case countrycode
        case phonenumber
        case iban
        case changepassword
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let headerView = settingsTableView.tableHeaderView else {
            return
        }
        let size = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            settingsTableView.tableHeaderView = headerView
            settingsTableView.layoutIfNeeded()
        }
    }
    
    

}

extension PersonalInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonalSettingTableViewCell", for: indexPath) as! PersonalSettingTableViewCell
        cell.labelView.text = settings[indexPath.row].name
        cell.img.image = settings[indexPath.row].image
        cell.accessoryType = .disclosureIndicator
        switch settings[indexPath.row].type {
        case .iban, .emailaddress, .changepassword:
            cell.accessoryType = .disclosureIndicator
            cell.labelView.alpha = 1
            cell.selectionStyle = .default
        default:
            cell.accessoryType = .none
            cell.labelView.alpha = 0.5
            cell.selectionStyle = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch settings[indexPath.row].type {
        case .iban:
            print("iban")
            let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeSettingViewController") as! ChangeSettingViewController
            vc.img = #imageLiteral(resourceName: "card")
            vc.titleOfInput = NSLocalizedString("ChangeIBAN", comment: "")
            vc.inputOfInput = UserDefaults.standard.userExt!.iban
            vc.validateFunction = { s in
                return self.validationHelper.isIbanChecksumValid(s)
            }
            vc.saveAction = { s in
                self.loginManager.changeIban(iban: s, callback: { (success) in
                    if success {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "", message: NSLocalizedString("EditPersonalSucces", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                                self.navigationController?.popViewController(animated: true)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong2", comment: ""), message: NSLocalizedString("EditPersonalFail", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                                
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                })
            }
            self.navigationController?.pushViewController(vc, animated: true)
        case .emailaddress:
            print("emailadres")
            let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeSettingViewController") as! ChangeSettingViewController
            vc.img = #imageLiteral(resourceName: "email_sign")
            vc.titleOfInput = NSLocalizedString("ChangeEmail", comment: "")
            vc.inputOfInput = UserDefaults.standard.userExt!.email
            vc.validateFunction = { s in
                return self.validationHelper.isEmailAddressValid(s)
            }
            vc.saveAction = { newEmail in
                SVProgressHUD.show()
                self.loginManager.checkTLD(email: newEmail, completionHandler: { (success) in
                    SVProgressHUD.dismiss()
                    if success {
                        self.loginManager.updateEmail(email: newEmail, completionHandler: { (success2) in
                            if success2 {
                                DispatchQueue.main.async {
                                    let alert = UIAlertController(title: "", message: NSLocalizedString("EditPersonalSucces", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                                        self.navigationController?.popViewController(animated: true)
                                    }))
                                    self.present(alert, animated: true, completion: nil)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong2", comment: ""), message: NSLocalizedString("EditPersonalFail", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                                        
                                    }))
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        })
                    } else {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong2", comment: ""), message: NSLocalizedString("ErrorTLDCheck", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                                
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                })
                print("saving email")
            }
            self.navigationController?.pushViewController(vc, animated: true)
        case .changepassword:
            print("password")
            let vc = UIStoryboard(name: "ForgotPassword", bundle: nil).instantiateInitialViewController() as! ForgotPasswordViewController
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            return
        }
    }
    
    
}
