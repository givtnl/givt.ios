//
//  FingerprintViewController.swift
//  ios
//
//  Created by Lennie Stockman on 11/09/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit
import Security
import LocalAuthentication

class FingerprintViewController: UIViewController {

    @IBOutlet var bodyText: UILabel!
    @IBOutlet var menuItem: UILabel!
    @IBOutlet var switchButton: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        switchButton.isOn = UserDefaults.standard.hasFingerprintSet
        if InfraManager.biometricType() == .touch {
            title = NSLocalizedString("TouchID", comment: "")
            menuItem.text = NSLocalizedString("TouchID", comment: "")
            bodyText.text = NSLocalizedString("TouchIDUsage", comment: "")
            
        } else if InfraManager.biometricType() == .face {
            title = NSLocalizedString("FaceID", comment: "")
            menuItem.text = NSLocalizedString("FaceID", comment: "")
            bodyText.text = NSLocalizedString("FaceIDUsage", comment: "")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func toggleSwitch(_ sender: Any) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrLabel as String: "Fingerprint",
            kSecAttrAccount as String: UserDefaults.standard.userExt!.guid]

        let sw = sender as! UISwitch
        if sw.isOn {
            let cannotUseTouchId = UIAlertController(title: NSLocalizedString("AuthenticationIssueTitle", comment: ""), message: NSLocalizedString("AuthenticationIssueMessage", comment: ""), preferredStyle: UIAlertController.Style.alert)
            cannotUseTouchId.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                sw.isOn = false
                UserDefaults.standard.hasFingerprintSet = false
            }))

            let authenticationContext = LAContext()
            authenticationContext.touchIDAuthenticationAllowableReuseDuration = 10
            var error: NSError?
            
            if authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                authenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: " ") { (didEvaluate, error) in
                    let doWhenCancel = { () in
                        LogService.shared.info(message: "User cancelled setting fingerprint")
                        DispatchQueue.main.async {
                            sw.isOn = false
                            UserDefaults.standard.hasFingerprintSet = false
                        }
                    }
                    
                    if didEvaluate {
                        let newFingerprint = NSUUID().uuidString.replacingOccurrences(of: "-", with: "") //strip dashes
                        self.showLoader()
                        LoginManager.shared.registerFingerprint(fingerprint: newFingerprint) { (success) in
                            self.hideLoader()
                            if success {
                                let doWhenSucces = { () in
                                    DispatchQueue.main.async {
                                        UserDefaults.standard.hasFingerprintSet = true
                                        sw.isOn = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
                                        self.sideMenuController?.hideLeftView(sender: self)
                                        self.backPressed(self)
                                    })
                                }
                                
                                let doWhenError = { (addedItemStatus: OSStatus) in
                                    LogService.shared.warning(message: "Something went wrong setting biometric (\(addedItemStatus))")
                                    DispatchQueue.main.async {
                                        sw.isOn = false
                                        self.present(cannotUseTouchId, animated: true, completion: nil)
                                    }
                                }
                                
                                let flags = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlocked, SecAccessControlCreateFlags.userPresence, nil)
                                let dict: [String: Any] = [kSecAttrLabel as String: "Fingerprint",
                                                           kSecValueData as String: newFingerprint.data(using: String.Encoding.utf8)!,
                                                           kSecAttrAccessControl as String: flags!,
                                                           kSecClass as String: kSecClassGenericPassword,
                                                           kSecAttrAccount as String: UserDefaults.standard.userExt!.guid]
                                
                                let addedItemStatus = SecItemAdd(dict as CFDictionary, nil)
                                switch addedItemStatus {
                                case errSecSuccess:
                                    LogService.shared.info(message: "Sucessfully saved biometric")
                                    doWhenSucces()
                                case errSecDuplicateItem:
                                    SecItemDelete(query as CFDictionary)
                                    let status = SecItemAdd(dict as CFDictionary, nil)
                                    switch status {
                                    case errSecSuccess:
                                        LogService.shared.info(message: "Sucessfully updated biometric")
                                        doWhenSucces()
                                    case errSecUserCanceled:
                                        doWhenCancel()
                                    default:
                                        doWhenError(addedItemStatus)
                                    }
                                case errSecUserCanceled:
                                    doWhenCancel()
                                default:
                                    doWhenError(addedItemStatus)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.present(cannotUseTouchId, animated: true, completion: nil)
                                    sw.isOn = false
                                }
                            }
                        }
                    } else {
                        doWhenCancel()
                    }
                }
            } else {
                self.present(cannotUseTouchId, animated: true, completion: nil)
            }
        } else {
            SecItemDelete(query as CFDictionary)
            UserDefaults.standard.hasFingerprintSet = false
        }
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
