//
//  PersonalInfoViewController.swift
//  ios
//
//  Created by Lennie Stockman on 30/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit
import SVProgressHUD
import GivtCodeShare

public enum SettingType {
    case name
    case emailaddress
    case address
    case countrycode
    case phonenumber
    case iban
    case changepassword
    case bacs
    case giftaid
    case creditCard
}

class PersonalInfoViewController: UIViewController, UITextFieldDelegate {
    var settings: [PersonalSetting]!
    private var _country: String = ""
    
    struct PersonalSetting {
        var image: UIImage
        var name: String
        var type: SettingType
    }
    
    private var validatedPhoneNumber: String = ""
    private let loginManager = LoginManager.shared
    private let validationHelper = ValidationHelper.shared
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet var titleText: UILabel!
    @IBOutlet var settingsTableView: UITableView!
    private var position: Int?
    private var deleting: Bool = false
    private var uExt: LMUserExt?
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        title = NSLocalizedString("TitlePersonalInfo", comment: "")
        settings = [PersonalSetting]()
        settingsTableView.tableFooterView = UIView()
        self.navigationController?.removeLogo()
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
        
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
        
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        lbl.font = UIFont(name: "Avenir-Light", size: 16.0)
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = NSLocalizedString("PersonalPageHeader", comment: "") + "\n\n" + NSLocalizedString("PersonalPageSubHeader", comment: "")
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(lbl)
        lbl.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        lbl.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20).isActive = true
        lbl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        lbl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true
        
        settingsTableView.tableHeaderView = containerView
        
        containerView.widthAnchor.constraint(equalTo: self.settingsTableView.widthAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: self.settingsTableView.centerXAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: self.settingsTableView.topAnchor, constant: 10).isActive = true
        
        self.settingsTableView.layoutIfNeeded()
        self.settingsTableView.tableHeaderView = self.settingsTableView.tableHeaderView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /* We may have lost internet connection when coming back from a personal info change setting viewcontroller */
        if AppServices.shared.isServerReachable {
            SVProgressHUD.show()
            loginManager.getUserExt { (userExtObject) in
                SVProgressHUD.dismiss()
                self.uExt = userExtObject
                guard let userExt = userExtObject else {
                    let alert = UIAlertController(title: NSLocalizedString("RequestFailed", comment: ""), message: NSLocalizedString("CantFetchPersonalInformation", comment: ""), preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                        DispatchQueue.main.async {
                            self.backPressed(self)
                        }
                    }))
                    return
                }
                self.settings.removeAll()

                switch(userExt.Country) {
                case "US":
                    self.settings.append(
                        PersonalSetting(
                            image: #imageLiteral(resourceName: "house"),
                            name: "United States",
                            type: .address
                        )
                    )
                    self.settings.append(
                        PersonalSetting(
                            image: #imageLiteral(resourceName: "phone_red"),
                            name: userExt.PhoneNumber,
                            type: .phonenumber
                        )
                    )
                    self.settings.append(
                        PersonalSetting(
                            image: #imageLiteral(resourceName: "email_sign"),
                            name: userExt.Email,
                            type: .emailaddress)
                    
                    )
                    let prefferedImageSize = self.settings.first { $0.type == .address }!.image.size
                    if let cardInfo = try? Mediater.shared.send(request: GetAccountsQuery()).result?.accounts?.first?.creditCardDetails  {
                        if let maskedCardNumber = cardInfo.cardNumber, let cardType = cardInfo.cardType {
                            let cardImage = getCreditCardCompanyLogo(getCreditCardCompanyEnumValue(value: cardType))
                            self.settings.append(
                                PersonalSetting(
                                    image: cardImage.resized(to: prefferedImageSize)!,
                                    name: maskedCardNumber.chunked(by: 4),
                                    type: .creditCard
                                )
                            )
                        }
                    }
                    break
                default:
                    self._country = AppConstants.countries.filter { (c) -> Bool in
                        c.shortName == userExt.Country
                        }[0].name
                    self.settings.append(PersonalSetting(image: #imageLiteral(resourceName: "personal_gray"), name: userExt.FirstName! + " " + userExt.LastName!, type: .name))
                    self.settings.append(PersonalSetting(image: #imageLiteral(resourceName: "email_sign"), name: userExt.Email, type: .emailaddress))
                    self.settings.append(PersonalSetting(image: #imageLiteral(resourceName: "house"), name: userExt.Address! + "\n" + userExt.PostalCode! + " " + userExt.City! + ", " + self._country, type: .address))
                    self.settings.append(PersonalSetting(image: #imageLiteral(resourceName: "phone_red"), name: userExt.PhoneNumber, type: .phonenumber))
                    if let iban = userExt.IBAN {
                        self.settings.append(PersonalSetting(image: #imageLiteral(resourceName: "card"), name: iban.separate(every: 4, with: " "), type: .iban))
                    } else if let sortCode = userExt.SortCode, let accountNumber = userExt.AccountNumber {
                        self.settings.append(PersonalSetting(image: #imageLiteral(resourceName: "card"), name: NSLocalizedString("BacsSortcodeAccountnumber", comment: "").replacingOccurrences(of: "{0}", with: sortCode).replacingOccurrences(of: "{1}", with: accountNumber), type: .bacs))
                    }
                    
                    if UserDefaults.standard.accountType == AccountType.bacs {
                        self.settings.append(PersonalSetting(image: #imageLiteral(resourceName: "Giftaid_Icon-yellow"), name: "Gift Aid", type: .giftaid))
                    }
                    break
                }
                
                
                
                self.settings.append(PersonalSetting(image: #imageLiteral(resourceName: "lock"), name: NSLocalizedString("ChangePassword", comment: ""), type: SettingType.changepassword))
                
                DispatchQueue.main.async {
                    self.settingsTableView.reloadData()
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let selectedRow = settingsTableView.indexPathForSelectedRow {
            settingsTableView.deselectRow(at: selectedRow, animated: false)
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
        
        if (UserDefaults.standard.paymentType == .CreditCard) {
            switch settings[indexPath.row].type {
                case .address, .creditCard:
                    cell.accessoryType = .none
                    cell.labelView.alpha = 0.5
                    cell.selectionStyle = .none
                    cell.img.image = cell.img.image!.noir.alpha(0.5)
                    cell.isUserInteractionEnabled = false
                break
                default:
                    cell.accessoryType = .disclosureIndicator
                    cell.labelView.alpha = 1
                    cell.selectionStyle = .default
                break
            }
            return cell
        }
        switch settings[indexPath.row].type {
        case .name:
            cell.accessoryType = .none
            cell.labelView.alpha = 0.5
            cell.selectionStyle = .none
            cell.img.image = cell.img.image!.noir
        case .emailaddress:
            cell.accessoryType = .disclosureIndicator
            cell.labelView.alpha = 1
            cell.selectionStyle = .default
            cell.labelView.numberOfLines = 1
        default:
            cell.accessoryType = .disclosureIndicator
            cell.labelView.alpha = 1
            cell.selectionStyle = .default
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (UserDefaults.standard.paymentType == .CreditCard) {
            let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeSettingViewController") as! ChangeSettingViewController
            vc.type = settings[indexPath.row].type
            vc.img = settings[indexPath.row].image
            switch settings[indexPath.row].type {
            case .phonenumber:
                vc.titleOfInput = "Change mobile number"
                vc.inputOfInput = uExt?.PhoneNumber
                vc.img = #imageLiteral(resourceName: "phone_red")
                vc.validateInput1 = { phoneNumber in
                    let validator = RegistrationValidator()
                    validator.phoneNumber = phoneNumber
                    return validator.isValidPhoneNumber
                }
                vc.saveAction = { phoneNumber in
                    NavigationManager.shared.reAuthenticateIfNeeded(context:self, completion: {
                        SVProgressHUD.show()
                        LoginManager.shared.getUserExt(completion: {(userExt) in
                            guard var userExt = userExt else {
                                DispatchQueue.main.async {
                                    let alert = UIAlertController(title: NSLocalizedString("SaveFailed", comment: ""), message: NSLocalizedString("UpdatePersonalInfoError", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in

                                    }))
                                    SVProgressHUD.dismiss()
                                    self.present(alert, animated: true, completion: nil)

                                }
                                return
                            }
                            userExt.PhoneNumber = phoneNumber
                            LoginManager.shared.updateUserExt(userExt: userExt, callback: {(success) in
                                SVProgressHUD.dismiss()
                                if success.ok {
                                    DispatchQueue.main.async {
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        let alert = UIAlertController(title: NSLocalizedString("SaveFailed", comment: ""), message: NSLocalizedString("UpdatePersonalInfoError", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in

                                        }))
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                }
                            })
                        })
                    })
                }
                break
            case .emailaddress:
                vc.img = #imageLiteral(resourceName: "email_sign")
                vc.type = settings[indexPath.row].type
                vc.titleOfInput = NSLocalizedString("ChangeEmail", comment: "")
                vc.inputOfInput = uExt?.Email
                vc.keyboardTypeOfInput = UIKeyboardType.emailAddress
                vc.validateInput1 = { emailAddress in
                    let validator = RegistrationValidator()
                    validator.emailAddress = emailAddress
                    return validator.isValidEmail
                }
                vc.saveAction = { email in
                    let newEmail = email.trimmingCharacters(in: CharacterSet.init(charactersIn: " "))
                    NavigationManager.shared.reAuthenticateIfNeeded(context: self, completion: {
                        SVProgressHUD.show()
                        self.loginManager.checkTLD(email: newEmail, completionHandler: { (success) in
                            if success {
                                if var uext = self.uExt {
                                    uext.Email = newEmail
                                    self.loginManager.updateUser(uext: uext, completionHandler: { (success2) in
                                        SVProgressHUD.dismiss()
                                        if success2 {
                                            DispatchQueue.main.async {
                                                self.navigationController?.popViewController(animated: true)
                                            }
                                        } else {
                                            DispatchQueue.main.async {
                                                let alert = UIAlertController(title: NSLocalizedString("SaveFailed", comment: ""), message: NSLocalizedString("UpdatePersonalInfoError", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                                                    
                                                }))
                                                self.present(alert, animated: true, completion: nil)
                                            }
                                        }
                                    })
                                }
                            } else {
                                SVProgressHUD.dismiss()
                                DispatchQueue.main.async {
                                    let alert = UIAlertController(title: NSLocalizedString("InvalidEmail", comment: ""), message: NSLocalizedString("ErrorTLDCheck", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                                        
                                    }))
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        })
                    })
                }
                break
            case .changepassword:
                let vc = UIStoryboard(name: "ForgotPassword", bundle: nil)
                    .instantiateInitialViewController() as! ForgotPasswordViewController
                self.navigationController?.pushViewController(vc, animated: true)
                return
            default:
                break
            }
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        switch settings[indexPath.row].type {
        case .phonenumber:
            let vc = storyboard?.instantiateViewController(withIdentifier: "ChangePhoneNumberViewController") as! ChangePhoneNumberViewController
            vc.currentPhoneNumber = uExt?.PhoneNumber
            self.navigationController?.pushViewController(vc, animated: true)
        case .iban:
            print("iban")
            let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeSettingViewController") as! ChangeSettingViewController
            vc.type = settings[indexPath.row].type
            vc.img = #imageLiteral(resourceName: "card")
            vc.titleOfInput = NSLocalizedString("ChangeIBAN", comment: "")
            vc.inputOfInput = settings[indexPath.row].name
            vc.validateInput1 = { s in
                return self.validationHelper.isIbanChecksumValid(s)
            }
            vc.saveAction = { s in
                NavigationManager.shared.reAuthenticateIfNeeded(context: self, completion: {
                    SVProgressHUD.show()
                    self.loginManager.getUserExt(completion: { (userExt) in
                        guard var userExt = userExt else
                        {
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: NSLocalizedString("SaveFailed", comment: ""), message: NSLocalizedString("UpdatePersonalInfoError", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                                    
                                }))
                                SVProgressHUD.dismiss()
                                self.present(alert, animated: true, completion: nil)
                            }
                            return
                        }
                        userExt.IBAN = s.replacingOccurrences(of: " ", with: "")
                        self.loginManager.updateUserExt(userExt: userExt, callback: { (success) in
                            SVProgressHUD.dismiss()
                            if success.ok {
                                DispatchQueue.main.async {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    let alert = UIAlertController(title: NSLocalizedString("SaveFailed", comment: ""), message: NSLocalizedString("UpdatePersonalInfoError", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                                        
                                    }))
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        })
                    })
                    
                })
            }
            self.navigationController?.pushViewController(vc, animated: true)
        case .bacs:
            print("bacs")
            let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeSettingViewController") as! ChangeSettingViewController
            vc.type = settings[indexPath.row].type
            vc.img = #imageLiteral(resourceName: "card")
            vc.titleOfInput = NSLocalizedString("ChangeBankAccountNumberAndSortCode", comment: "")
            if let uExt = self.uExt {
                vc.inputOfInput = uExt.SortCode
                vc.inputOfInput2 = uExt.AccountNumber
            }
            vc.validateInput1 = { s in
                return self.validationHelper.isValidSortcode(s: s)
            }
            vc.validateInput2 = { s in
                return self.validationHelper.isValidAccountNumber(s: s)
            }

            vc.saveAction2 = { sortCode, accountNumber in
                self.uExt?.SortCode = sortCode
                self.uExt?.AccountNumber = accountNumber
                NavigationManager.shared.reAuthenticateIfNeeded(context: self, completion: {
                    SVProgressHUD.show()
                    self.loginManager.updateUserExt(userExt: self.uExt!) { (result) in
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                        }
                        if result.ok {
                            DispatchQueue.main.async {
                                self.backPressed(self)
                            }
                        } else {
                            let alert = UIAlertController(title: NSLocalizedString("SaveFailed", comment: ""), message: NSLocalizedString("UpdatePersonalInfoError", comment: ""), preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil ))
                            
                            if(result.error == 111){
                                alert.title = NSLocalizedString("DDIFailedTitle", comment: "")
                                alert.message = NSLocalizedString("UpdateBacsAccountDetailsError", comment: "")
                            } else if (result.error == 112){
                                alert.title = NSLocalizedString("DDIFailedTitle", comment: "")
                                alert.message = NSLocalizedString("DDIFailedMessage", comment: "")
                            }
                            DispatchQueue.main.async {
                                self.present(alert, animated: true, completion:nil)
                            }
                        }
                    }
                })
            }
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .emailaddress:
            print("emailadres")
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeSettingViewController") as! ChangeSettingViewController
            vc.img = #imageLiteral(resourceName: "email_sign")
            vc.type = settings[indexPath.row].type
            vc.titleOfInput = NSLocalizedString("ChangeEmail", comment: "")
            vc.inputOfInput = settings[indexPath.row].name
            vc.keyboardTypeOfInput = UIKeyboardType.emailAddress
            vc.validateInput1 = { s in
                return self.validationHelper.isEmailAddressValid(s.trimmingCharacters(in: CharacterSet.init(charactersIn: " ")))
            }
            vc.saveAction = { email in
                let newEmail = email.trimmingCharacters(in: CharacterSet.init(charactersIn: " "))
                NavigationManager.shared.reAuthenticateIfNeeded(context: self, completion: {
                    SVProgressHUD.show()
                    self.loginManager.checkTLD(email: newEmail, completionHandler: { (success) in
                        if success {
                            if var uext = self.uExt {
                                uext.Email = newEmail
                                self.loginManager.updateUser(uext: uext, completionHandler: { (success2) in
                                    SVProgressHUD.dismiss()
                                    if success2 {
                                        DispatchQueue.main.async {
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            let alert = UIAlertController(title: NSLocalizedString("SaveFailed", comment: ""), message: NSLocalizedString("UpdatePersonalInfoError", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                                                
                                            }))
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                    }
                                })
                            }
                        } else {
                            SVProgressHUD.dismiss()
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: NSLocalizedString("InvalidEmail", comment: ""), message: NSLocalizedString("ErrorTLDCheck", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                                    
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    })
                })
                
                print("saving email")
            }
            self.navigationController?.pushViewController(vc, animated: true)
        case .changepassword:
            print("password")
            let vc = UIStoryboard(name: "ForgotPassword", bundle: nil).instantiateInitialViewController() as! ForgotPasswordViewController
            self.navigationController?.pushViewController(vc, animated: true)
        case .address:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChangeAddressViewController") as! ChangeAddressViewController
            vc.uExt = self.uExt
            self.navigationController?.pushViewController(vc, animated: true)
        case .giftaid:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GiftAidViewController") as! GiftAidViewController
            vc.uExt = self.uExt
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            return
        }
    }
}
