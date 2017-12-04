//
//  PersonalInfoViewController.swift
//  ios
//
//  Created by Lennie Stockman on 30/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit
import SVProgressHUD

class PersonalInfoViewController: UIViewController, UITextFieldDelegate {

    private let loginManager = LoginManager.shared
    private let validationHelper = ValidationHelper.shared
    @IBOutlet var btnNext: CustomButton!
    @IBOutlet var iban: CustomUITextField!
    @IBOutlet var cellphone: UILabel!
    @IBOutlet var postal: UILabel!
    @IBOutlet var street: UILabel!
    @IBOutlet var email: UILabel!
    @IBOutlet var name: UILabel!
    var countries = [Country]()
    
    var ibanNumber: String? = "" {
        didSet {
           // iban.text = ibanNumber?.replacingOccurrences(of: " ", with: "").separate(every: 4, with: " ")
          //  iban.text = ibanNumber?.replacingOccurrences(of: " ", with: "").replace((.{4})/," ")
            iban.text = ibanNumber
            if let i = ibanNumber {
                let isIbanValid = validationHelper.isIbanChecksumValid(i)
                iban.setState(b: isIbanValid)
                btnNext.isEnabled = isIbanValid
            }
            iban.text = ibanNumber?.replacingOccurrences(of: " ", with: "").separate(every: 4, with: " ")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.returnKeyType == .done {
            save()
        }
        return false
    }
    @IBAction func next(_ sender: Any) {
        save()
    }
    
    func save() {
        SVProgressHUD.show()
        loginManager.changeIban(iban: ibanNumber!.replacingOccurrences(of: " ", with: "")) { (success) in
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
    
    func textFieldDidChange(_ textField: UITextField) {
        if textField == iban {
            ibanNumber = iban.text
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
        
        iban.delegate = self
        iban.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        
        iban.text = ""
        name.text = ""
        email.text = ""
        street.text = ""
        postal.text = ""
        cellphone.text = ""
        // Do any additional setup after loading the view.
        
        iban.placeholder = NSLocalizedString("IBANPlaceHolder", comment: "")
        btnNext.setTitle(NSLocalizedString("ButtonChange", comment: ""), for: .normal)
        
        btnNext.isEnabled = false
        
        countries.append(Country(name: NSLocalizedString("Belgium", comment: ""), shortName: "BE", prefix: "+32"))
        countries.append(Country(name: NSLocalizedString("Netherlands", comment: ""), shortName: "NL", prefix: "+31"))
        countries.append(Country(name: NSLocalizedString("Germany", comment: ""), shortName: "DE", prefix: "+49"))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let user = UserDefaults.standard.userExt {
            var country = ""
            if let idx = Int(user.countryCode) {
                country = countries[idx].shortName
            } else {
                country = user.countryCode
            }
            ibanNumber = user.iban
            print(user.iban)
            name.text = user.firstName + " " + user.lastName
            email.text = user.email
            street.text = user.address
            postal.text = user.postalCode + " " + user.city + ", " + country
            cellphone.text = user.mobileNumber
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
