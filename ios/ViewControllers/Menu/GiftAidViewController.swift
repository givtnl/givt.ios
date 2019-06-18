//
//  GiftAidViewController.swift
//  ios
//
//  Created by Bjorn Derudder on 07/06/2019.
//  Copyright © 2019 Givt. All rights reserved.
//

import Foundation
import SVProgressHUD
import UIKit

class GiftAidViewController: UIViewController {
    
    var uExt: LMUserExt?
    private let loginManager = LoginManager.shared
    var comingFromRegistration = false
        private var log: LogService = LogService.shared
    
    @IBOutlet weak var giftAidSwitch: UISwitch!
    @IBOutlet weak var lblSettings: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblHeaderDisclaimer: UILabel!
    @IBOutlet weak var lblBodyDisclaimer: UILabel!
    @IBOutlet weak var btnSave: CustomButton!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var helpViewController = UIStoryboard(name: "Personal", bundle: nil).instantiateViewController(withIdentifier: "GiftAidInfoController") as! GiftAidInfoController
    
    @IBAction func readyAction(_ sender: Any) {
        LoginManager.shared.updateUser(uext: self.uExt!, completionHandler: { (ok) in
            if ok {
                DispatchQueue.main.async {
                    self.backPressed(self)
                }
            } else {
                let alertController = UIAlertController(title: "Oops", message:
                    "Something went wrong" , preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default))
                
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func openInfo(_ sender: Any) {
                helpViewController.title = NSLocalizedString("GiftAidInfo_Title", comment: "")
                helpViewController.bodyText = NSLocalizedString("GiftAidInfo_Body", comment: "")
                self.present(helpViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        giftAidSwitch.setOn(uExt?.GiftAid != nil, animated: false)
        
        lblSettings.text = NSLocalizedString("GiftAid_Setting", comment:"")
        lblInfo.text = NSLocalizedString("GiftAid_Info", comment: "")
        lblHeaderDisclaimer.text = NSLocalizedString("GiftAid_HeaderDisclaimer", comment:"")
        lblBodyDisclaimer.text = NSLocalizedString("GiftAid_BodyDisclaimer", comment: "")
        
        if comingFromRegistration {
            self.btnBack.isEnabled = false;
            self.btnBack.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            self.btnBack.image = UIImage()
        }
    }
    
    override func viewDidLayoutSubviews() {
        let calcHeight = scrollView.subviews[0].subviews[0].frame.size.height +
                         scrollView.subviews[0].subviews[1].frame.size.height +
                         scrollView.subviews[0].subviews[2].frame.size.height + 50
        scrollView.contentSize =  CGSize(width: scrollView.subviews[0].frame.size.width,
                                         height: calcHeight)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        self.endEditing()
        let giftaidOn = giftAidSwitch.isOn
        if (giftaidOn) {
            uExt?.GiftAid = Date()
        } else {
            uExt?.GiftAid = nil
        }

        if comingFromRegistration {
            if NavigationManager.shared.hasInternetConnection(context: self) {
                SVProgressHUD.show()
                LoginManager.shared.requestMandateUrl(completionHandler: { (response) in
                    SVProgressHUD.dismiss()
                    if let r = response {
                        if(r.status == .ok){
                            LoginManager.shared.finishMandateSigning(completionHandler: { (done) in
                                print(done)
                            })
                            DispatchQueue.main.async {
                                let vc = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "FinalRegistrationViewController") as! FinalRegistrationViewController
                                self.navigationController!.pushViewController(vc, animated: true)
                            }
                        } else {
                            let alert = UIAlertController(title: NSLocalizedString("RequestFailed", comment: ""), message: NSLocalizedString("RequestMandateFailed", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (actions) in
                                DispatchQueue.main.async {
                                    self.dismiss(animated: true, completion: nil)
                                    NavigationManager.shared.loadMainPage(animated: false)
                                }
                            }))
                            if let data = r.data {
                                do {
                                    let parsedData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                                    if let parsedCode = parsedData["Code"] as? Int {
                                        if(parsedCode == 111){
                                            alert.title = NSLocalizedString("DDIFailedTitle", comment: "")
                                            alert.message = NSLocalizedString("UpdateBacsAccountDetailsError", comment: "")
                                        } else if (parsedCode == 112){
                                            alert.title = NSLocalizedString("DDIFailedTitle", comment: "")
                                            alert.message = NSLocalizedString("DDIFailedMessage", comment: "")
                                        }
                                    }
                                } catch {
                                    self.log.error(message: "Could not parse givtStatusCode Json probably not valid.")
                                }
                            }
                            DispatchQueue.main.async {
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                })
            }
        }
        else {
            if let userExt = uExt {
                self.loginManager.updateUser(uext: userExt, completionHandler: {(success) in
                    if success {
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: NSLocalizedString("SaveFailed", comment: ""), message: NSLocalizedString("UpdatePersonalInfoError", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                                
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                })
            }
        }
    }
}
