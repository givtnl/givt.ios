//
//  PinScreenViewController.swift
//  ios
//
//  Created by Lennie Stockman on 21/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit
import AudioToolbox
import SVProgressHUD

class PinScreenViewController: UIViewController {

    var innerHandler : ((Bool) -> Void)?
    
    @IBOutlet var btnForgotPin: UIButton!
    @IBOutlet var removeBtn: UIButton!
    @IBOutlet weak var backButton: UIBarButtonItem!
    var isDisabled: Bool = false
    var pincode: String = "" {
        didSet {
          
            switch pincode.count {
            case 0:
                UIView.animate(withDuration: 0.35, animations: {
                    self.removeBtn.alpha = 0.2
                })
                firstBullet.isHidden = true
                secondBullet.isHidden = true
                thirdBullet.isHidden = true
                fourthBullet.isHidden = true
            case 1:
                UIView.animate(withDuration: 0.35, animations: {
                    self.removeBtn.alpha = 1
                })
                firstBullet.isHidden = false
                secondBullet.isHidden = true
            case 2:
                secondBullet.isHidden = false
                thirdBullet.isHidden = true
            case 3:
                thirdBullet.isHidden = false
                fourthBullet.isHidden = true
            case 4:
                fourthBullet.isHidden = false
                

                
            default:
                //do nothun
                break
            }
        
        }
    }
    var pincodeCheck: String = ""
    @IBOutlet var firstBullet: UILabel!
    @IBOutlet var secondBullet: UILabel!
    @IBOutlet var thirdBullet: UILabel!
    @IBOutlet var fourthBullet: UILabel!
    @IBOutlet var subtitle: UILabel!
    private var typeOfPin: TypeOfPin?
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
        title = NSLocalizedString("PincodeSetPinTitle", comment: "")
        subtitle.text = NSLocalizedString("PincodeSetPinMessage", comment: "")
        btnForgotPin.isHidden = true
        if let nc = self.navigationController as? PinNavViewController {
            self.typeOfPin = nc.typeOfPin
        }
        
        if typeOfPin == .login {
            title = NSLocalizedString("Pincode", comment: "")
            subtitle.text = NSLocalizedString("LoginPincode", comment: "")
            btnForgotPin.isHidden = false
        }
        
        btnForgotPin.setTitle(NSLocalizedString("PincodeForgotten", comment: ""), for: .normal)
        
        pincode = ""
        // Do any additional setup after loading the view.
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addValue(_ sender: Any) {
        if isDisabled || pincode.count == 4 {
            return
        }

        if let btn = sender as? UIButton, let value = btn.titleLabel?.text {
            pincode += value
        }
        
        if pincode.count == 4 {
            if typeOfPin == .login {
                SVProgressHUD.show()
                LoginManager.shared.loginUser(email: UserDefaults.standard.userExt!.email, password: pincode, type: .pincode, completionHandler: { (status, description) in
                    SVProgressHUD.dismiss()
                    if let descr = description, !status {
                        DispatchQueue.main.async {
                            self.animateBullets()
                            AppServices.shared.vibrate()
                        }
                        
                        var alert: UIAlertController? = UIAlertController(title: NSLocalizedString("PincodeWrongPinTitle", comment: ""), message: "", preferredStyle: .alert)
                        
                        switch descr {
                        case "OneAttemptLeft":
                            alert!.message = NSLocalizedString("PincodeWrongPinSecondTry", comment: "")
                            alert!.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                self.pincode = ""
                            }))
                        case "TwoAttemptsLeft":
                            alert!.message = NSLocalizedString("PincodeWrongPinFirstTry", comment: "")
                            alert!.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                self.pincode = ""
                            }))
                        case "PinWiped":
                            UserDefaults.standard.hasPinSet = false
                            alert!.message = NSLocalizedString("PincodeWrongPinThirdTry", comment: "")
                            alert!.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                self.pincode = ""
                                self.dismiss(animated: true, completion: {
                                    self.innerHandler!(false)
                                })
                            }))
                        default:
                            if descr == "WrongPassOrUser" || descr == "AccountDisabled" {
                                UserDefaults.standard.hasPinSet = false
                            }
                            alert = nil
                            ErrorHandlingHelper.ShowLoginError(context: self, error: descr)
                        }
                        
                        if let alert = alert {
                            DispatchQueue.main.async {
                                self.present(alert, animated: true, completion: nil)
                            }
                        }

                    } else if status {
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: { self.innerHandler!(true) } )
                        }
                    } else {
                        let alert = UIAlertController(title: NSLocalizedString("PincodeWrongPinTitle", comment: ""), message: "", preferredStyle: .alert)
                        alert.title = NSLocalizedString("SomethingWentWrong", comment: "")
                        alert.message = NSLocalizedString("ConnectionError", comment: "")
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.pincode = ""
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                })
            } else {
                if pincodeCheck.isEmpty() {
                    isDisabled = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
                        self.subtitle.text = NSLocalizedString("PincodeEnterPinAgain", comment: "")
                        self.pincodeCheck = self.pincode
                        self.pincode = ""
                        self.isDisabled = false
                    })
                } else {
                    if pincode == pincodeCheck {
                        SVProgressHUD.show()
                        LoginManager.shared.registerPin(pin: pincode, completionHandler: { (status) in
                            if status {
                                SVProgressHUD.dismiss()
                                UserDefaults.standard.hasPinSet = true
                                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                                    self.subtitle.text = NSLocalizedString("PincodeSuccessfullTitle", comment: "")
                                    let alert = UIAlertController(title: NSLocalizedString("PincodeSuccessfullTitle", comment: ""), message: NSLocalizedString("PincodeSuccessfullMessage", comment: ""), preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                        //register pin
                                        self.dismiss(animated: true, completion: nil)
                                    }))
                                    self.present(alert, animated: true, completion: {
                                        
                                    })
                                })
                            } else {
                                SVProgressHUD.dismiss()
                                let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("ConnectionError", comment: ""), preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion:  nil)
                            }
                        })
                        
                        
                    } else {
                        isDisabled = true
                        
                        self.animateBullets()
                        AppServices.shared.vibrate()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
                            self.subtitle.text = NSLocalizedString("PincodeSetPinMessage", comment: "")
                            let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("PincodeDoNotMatch", comment: ""), preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("TryAgain", comment: ""), style: .default, handler: { (action) in
                                self.pincode = ""
                                self.pincodeCheck = ""
                            }))
                            self.present(alert, animated: true, completion: {
                                self.isDisabled = false
                            })
                        })
                    }
                    
                }
            }
            
            
        }
    }
    
    @IBAction func removeValue(_ sender: Any) {
        if isDisabled {
            return
        }
        
        if pincode.count == 0 {
            return
        }
        
        let lastIndex = pincode.index(pincode.endIndex, offsetBy: -1)
        pincode = String(pincode[..<lastIndex])
    }
    
    func animateBullets() {
        DispatchQueue.main.async {
            self.addAnimation(view: self.firstBullet)
            self.addAnimation(view: self.secondBullet)
            self.addAnimation(view: self.thirdBullet)
            self.addAnimation(view: self.fourthBullet)
        }
    }
    @IBAction func forgotPin(_ sender: Any) {
        UserDefaults.standard.hasPinSet = false
        self.dismiss(animated: true, completion: {
            self.innerHandler!(false)
        })
    }
    
    func addAnimation(view: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.06
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: view.frame.midX - 10, y: view.frame.midY)
        animation.toValue = CGPoint(x: view.frame.midX + 10, y: view.frame.midY)
        view.layer.add(animation, forKey: "position")
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
