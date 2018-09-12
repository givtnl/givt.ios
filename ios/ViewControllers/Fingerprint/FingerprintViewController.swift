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
    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrLabel as String: "Fingerprint"]
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
                LoginManager.shared.registerFingerprint(fingerprint: newFingerprint) { (success) in
                    if success {
                        print("saved fingerprint")
                        let flags = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlocked, SecAccessControlCreateFlags.userPresence, nil)
                        var dict: [String: Any] = [kSecAttrLabel as String: "Fingerprint",
                                                   kSecValueData as String: newFingerprint.data(using: String.Encoding.utf8)!,
                                                   kSecAttrAccessControl as String: flags!]
                        let status = SecItemUpdate(self.query as CFDictionary, dict as CFDictionary)
                        
                        if status == errSecItemNotFound {
                            dict[kSecClass as String] = kSecClassGenericPassword
                            SecItemAdd(dict as CFDictionary, nil)
                        } else if status == errSecSuccess {
                            DispatchQueue.main.async {
                                sw.isOn = false
                            }
                            UserDefaults.standard.hasFingerprintSet = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
                                self.hideLeftView(self)
                                self.backPressed(self)
                            })
                        } else if status == errSecUserCanceled {
                            DispatchQueue.main.async {
                                sw.isOn = false
                                UserDefaults.standard.hasFingerprintSet = false
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.present(cannotUseTouchId, animated: true, completion: nil)
                            }
                        }
                    }
                }
            } else {
                self.present(cannotUseTouchId, animated: true, completion: nil)
            }
        } else {
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
