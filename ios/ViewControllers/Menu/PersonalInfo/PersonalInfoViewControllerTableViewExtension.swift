//
//  PersonalInfoViewControllerTableViewExtension.swift
//  ios
//
//  Created by Mike Pattyn on 10/02/2022.
//  Copyright © 2022 Givt. All rights reserved.
//

import Foundation
import UIKit
import GivtCodeShare
import SVProgressHUD
import SwipeCellKit

extension PersonalInfoViewController: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right, settings[indexPath.row].type == .creditCard else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Remove payment method") { action, indexPath in
            let alert = UIAlertController(title: "Info", message: "Do you want to remove this payment method?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) { yesAction in
                self.settings.remove(at: indexPath.row)
                action.fulfill(with: .delete)
                tableView.reloadData()
                return
            })
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { noAction in
                action.fulfill(with: .reset)
                tableView.reloadData()
            }))
            self.present(alert, animated: true, completion: nil)
        }
        return [deleteAction]
    }
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .selection
        options.transitionStyle = .reveal
        return options
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonalSettingTableViewCell", for: indexPath) as! PersonalSettingTableViewCell
        cell.delegate = self
        let currentSetting = settings[indexPath.row]
        cell.labelView.text = currentSetting.name
        cell.img.image = currentSetting.image
        
        if currentSetting.disabled && currentSetting.type != .creditCard {
            cell.accessoryType = .none
            cell.labelView.alpha = 0.5
            cell.selectionStyle = .none
            switch(currentSetting.type) {
                case .address:
                    cell.img.image = cell.img.image!.noir.alpha(0.5)
                default:
                    cell.img.image = cell.img.image!.noir.alpha(1)
            }
            cell.isUserInteractionEnabled = false
        } else {
            cell.accessoryType = .disclosureIndicator
            cell.labelView.alpha = 1
            cell.selectionStyle = .default
            cell.isUserInteractionEnabled = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (UserDefaults.standard.paymentType == .CreditCard) {
            let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeSettingViewController") as! ChangeSettingViewController
            
            guard settings[indexPath.row].type != .creditCard else { return tableView.deselectRow(at: indexPath, animated: true)}
                
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
                        LoginManager.shared.checkTLD(email: newEmail, completionHandler: { (success) in
                            if success {
                                if var uext = self.uExt {
                                    uext.Email = newEmail
                                    LoginManager.shared.updateUser(uext: uext, completionHandler: { (success2) in
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
                return ValidationHelper.shared.isIbanChecksumValid(s)
            }
            vc.saveAction = { s in
                NavigationManager.shared.reAuthenticateIfNeeded(context: self, completion: {
                    SVProgressHUD.show()
                    LoginManager.shared.getUserExt(completion: { (userExt) in
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
                        LoginManager.shared.updateUserExt(userExt: userExt, callback: { (success) in
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
                return ValidationHelper.shared.isValidSortcode(s: s)
            }
            vc.validateInput2 = { s in
                return ValidationHelper.shared.isValidAccountNumber(s: s)
            }
            
            vc.saveAction2 = { sortCode, accountNumber in
                self.uExt?.SortCode = sortCode
                self.uExt?.AccountNumber = accountNumber
                NavigationManager.shared.reAuthenticateIfNeeded(context: self, completion: {
                    SVProgressHUD.show()
                    LoginManager.shared.updateUserExt(userExt: self.uExt!) { (result) in
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
                return ValidationHelper.shared.isEmailAddressValid(s.trimmingCharacters(in: CharacterSet.init(charactersIn: " ")))
            }
            vc.saveAction = { email in
                let newEmail = email.trimmingCharacters(in: CharacterSet.init(charactersIn: " "))
                NavigationManager.shared.reAuthenticateIfNeeded(context: self, completion: {
                    SVProgressHUD.show()
                    LoginManager.shared.checkTLD(email: newEmail, completionHandler: { (success) in
                        if success {
                            if var uext = self.uExt {
                                uext.Email = newEmail
                                LoginManager.shared.updateUser(uext: uext, completionHandler: { (success2) in
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
