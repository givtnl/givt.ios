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
    var query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrLabel as String: "Fingerprint", kSecUseOperationPrompt as String: "Gebruik je vingerafdruk om in te loggen.", kSecAttrAccount as String: UserDefaults.standard.userExt!.email]
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
        query[kSecUseOperationPrompt as String] = NSLocalizedString("FingerprintMessageAlert", comment: "")
                                                    .replacingOccurrences(of: "{0}", with: title!)
                                                    .replacingOccurrences(of: "{1}", with: UserDefaults.standard.userExt!.email)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleSwitch(_ sender: Any) {
        let sw = sender as! UISwitch
        if sw.isOn {
            let cannotUseTouchId = UIAlertController(title: NSLocalizedString("AuthenticationIssueTitle", comment: ""), message: NSLocalizedString("AuthenticationIssueMessage", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            cannotUseTouchId.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                sw.isOn = false
                UserDefaults.standard.hasFingerprintSet = false
            }))
            
            let authenticationContext = LAContext()
            authenticationContext.touchIDAuthenticationAllowableReuseDuration = 10
            var error: NSError?
            if authenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                let newFingerprint = NSUUID().uuidString.replacingOccurrences(of: "-", with: "") //strip dashes
                showLoader()
                LoginManager.shared.registerFingerprint(fingerprint: newFingerprint) { (success) in
                    self.hideLoader()
                    if success {
                        let flags = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlocked, SecAccessControlCreateFlags.userPresence, nil)
                        var dict: [String: Any] = [kSecAttrLabel as String: "Fingerprint",
                                                   kSecValueData as String: newFingerprint.data(using: String.Encoding.utf8)!,
                                                   kSecAttrAccessControl as String: flags!,
                                                   kSecAttrAccount as String: UserDefaults.standard.userExt!.email]
                        // save empty key
                        var initialSave = dict
                        initialSave[kSecClass as String] = kSecClassGenericPassword
                        initialSave[kSecValueData as String] = "".data(using: .utf8)
                        let addedItemStatus = SecItemAdd(initialSave as CFDictionary, nil)
                        if addedItemStatus == errSecSuccess || addedItemStatus == errSecDuplicateItem {
                            LogService.shared.info(message: "Sucessfully saved fingerprint for the first time")
                            //update the item - force touch id to trigger
                            let status = SecItemUpdate(self.query as CFDictionary, dict as CFDictionary)
                            if status == errSecSuccess {
                                LogService.shared.info(message: "Sucessfully saved fingerprint for the first type")
                                DispatchQueue.main.async {
                                    sw.isOn = true
                                }
                                UserDefaults.standard.hasFingerprintSet = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
                                    self.hideLeftView(self)
                                    self.backPressed(self)
                                })
                            } else if status == errSecUserCanceled {
                                LogService.shared.info(message: "User cancelled setting fingerprint")
                                DispatchQueue.main.async {
                                    sw.isOn = false
                                    UserDefaults.standard.hasFingerprintSet = false
                                }
                            } else {
                                LogService.shared.warning(message: "Something went wrong setting fingerprint for the first time (\(status))")
                                DispatchQueue.main.async {
                                    self.present(cannotUseTouchId, animated: true, completion: nil)
                                }
                            }
                        } else {
                            LogService.shared.warning(message: "Something went wrong setting fingerprint for the first time (\(addedItemStatus))")
                            DispatchQueue.main.async {
                                self.present(cannotUseTouchId, animated: true, completion: nil)
                            }
                        }
                        print("saved fingerprint")
                
                    } else {
                        DispatchQueue.main.async {
                            self.present(cannotUseTouchId, animated: true, completion: nil)
                        }
                    }
                }
            } else {
                self.present(cannotUseTouchId, animated: true, completion: nil)
            }
        } else {
            SecItemDelete(self.query as CFDictionary)
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
