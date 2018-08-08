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
    var settings: [PersonalSetting]!
   private var _country: String = ""
    
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
        SVProgressHUD.show()
        loginManager.getUserExtObject { (userExtObject) in
            SVProgressHUD.dismiss()
            self.uExt = userExtObject
            guard let userExt = userExtObject else {
                /* TODO: @Lennie Why a guard if the user does not receive an error message? */
                DispatchQueue.main.async {
                    self.backPressed(self)
                }
                return
            }
            self._country = AppConstants.countries.filter { (c) -> Bool in
                c.shortName == userExt.Country
            }[0].name
            
            self.settings.removeAll()
            self.settings.append(PersonalSetting(image: #imageLiteral(resourceName: "personal_gray"), name: userExt.FirstName + " " + userExt.LastName, type: .name))
            self.settings.append(PersonalSetting(image: #imageLiteral(resourceName: "email_sign"), name: userExt.Email, type: .emailaddress))
            self.settings.append(PersonalSetting(image: #imageLiteral(resourceName: "house"), name: userExt.Address + "\n" + userExt.PostalCode + " " + userExt.City + ", " + self._country, type: .address))
            //self.settings.append(PersonalSetting(image: #imageLiteral(resourceName: "location"), name: userExt.PostalCode + " " + userExt.City + ", " + self._country, type: .countrycode))
            self.settings.append(PersonalSetting(image: #imageLiteral(resourceName: "phone_red"), name: userExt.PhoneNumber, type: .phonenumber))
            self.settings.append(PersonalSetting(image: #imageLiteral(resourceName: "card"), name: userExt.IBAN.separate(every: 4, with: " "), type: .iban))
            self.settings.append(PersonalSetting(image: #imageLiteral(resourceName: "green_lock"), name: NSLocalizedString("ChangePassword", comment: ""), type: PersonalInfoViewController.SettingType.changepassword))
            DispatchQueue.main.async {
                self.settingsTableView.reloadData()
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
        cell.accessoryType = .disclosureIndicator
        switch settings[indexPath.row].type {
        case .iban, .emailaddress, .changepassword, .phonenumber, .address:
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
        case .phonenumber:
            let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeSettingViewController") as! ChangeSettingViewController
            vc.img = #imageLiteral(resourceName: "phone_red")
            vc.titleOfInput = NSLocalizedString("ChangePhone", comment: "")
            vc.inputOfInput = settings[indexPath.row].name

            vc.validateFunction = { newPhone in
                let phoneResult = self.validationHelper.isValidPhone(number: newPhone)
                if(phoneResult.IsValid){
                    self.validatedPhoneNumber = phoneResult.Number!!
                }
                return phoneResult.IsValid
            }
            vc.saveAction = { newPhone in
                SVProgressHUD.show()
                NavigationManager.shared.reAuthenticateIfNeeded(context:self, completion: {
                    self.loginManager.getUserExtObject(completion: {(userExt) in
                        guard let userExt = userExt else {
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong2", comment: ""), message: NSLocalizedString("EditPersonalFail", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                                    
                                }))
                                SVProgressHUD.dismiss()
                                self.present(alert, animated: true, completion: nil)
                                
                            }
                            return
                        }
                        self.loginManager.changePhone(userExt: userExt, phone: self.validatedPhoneNumber.replacingOccurrences(of: " ", with: ""), callback: {(success) in
                            SVProgressHUD.dismiss()
                            if success {
                                DispatchQueue.main.async {
                                    self.navigationController?.popViewController(animated: true)
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
                    })
                })
            }
            self.navigationController?.pushViewController(vc, animated: true)

        case .iban:
            print("iban")
            let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeSettingViewController") as! ChangeSettingViewController
            vc.img = #imageLiteral(resourceName: "card")
            vc.titleOfInput = NSLocalizedString("ChangeIBAN", comment: "")
            vc.inputOfInput = settings[indexPath.row].name
            vc.validateFunction = { s in
                return self.validationHelper.isIbanChecksumValid(s)
            }
            vc.saveAction = { s in
                SVProgressHUD.show()
                NavigationManager.shared.reAuthenticateIfNeeded(context: self, completion: {
                    self.loginManager.getUserExtObject(completion: { (userExt) in
                        guard let userExt = userExt else
                        {
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong2", comment: ""), message: NSLocalizedString("EditPersonalFail", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                                    
                                }))
                                SVProgressHUD.dismiss()
                                self.present(alert, animated: true, completion: nil)
                            }
                            return
                        }
                        self.loginManager.changeIban(userExt: userExt,iban: s.replacingOccurrences(of: " ", with: ""), callback: { (success) in
                            SVProgressHUD.dismiss()
                            if success {
                                DispatchQueue.main.async {
                                    self.navigationController?.popViewController(animated: true)
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
                    })
                    
                })
            }
            self.navigationController?.pushViewController(vc, animated: true)
        case .emailaddress:
            print("emailadres")
            let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeSettingViewController") as! ChangeSettingViewController
            vc.img = #imageLiteral(resourceName: "email_sign")
            vc.titleOfInput = NSLocalizedString("ChangeEmail", comment: "")
            vc.inputOfInput = settings[indexPath.row].name
            vc.validateFunction = { s in
                return self.validationHelper.isEmailAddressValid(s)
            }
            vc.saveAction = { newEmail in
                SVProgressHUD.show()
                self.loginManager.checkTLD(email: newEmail, completionHandler: { (success) in
                    if success {
                        self.loginManager.updateEmail(email: newEmail, completionHandler: { (success2) in
                            SVProgressHUD.dismiss()
                            if success2 {
                                DispatchQueue.main.async {
                                    self.navigationController?.popViewController(animated: true)
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
                        SVProgressHUD.dismiss()
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
        case .address:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChangeAddressViewController") as! ChangeAddressViewController
            vc.uExt = self.uExt
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            return
        }
    }
    
    
}
