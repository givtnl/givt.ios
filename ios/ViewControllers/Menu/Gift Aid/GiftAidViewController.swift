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
import AppCenterAnalytics
import Mixpanel

class GiftAidViewController: UIViewController {
    
    var uExt: LMUserExt?
    private var previousStateGiftAid: Bool?
    private let loginManager = LoginManager.shared
    var comingFromRegistration: Bool = false
        private var log: LogService = LogService.shared
    var shouldAskForGiftAidPermission: Bool? = false
    @IBOutlet weak var giftAidSwitch: UISwitch!
    @IBOutlet weak var lblSettings: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblHeaderDisclaimer: UILabel!
    @IBOutlet weak var lblBodyDisclaimer: UILabel!
    @IBOutlet weak var btnSave: CustomButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var helpViewController = UIStoryboard(name: "Personal", bundle: nil).instantiateViewController(withIdentifier: "GiftAidInfoController") as! GiftAidInfoController
    
    override func viewDidLoad() {
        
        if let shouldShowGiftAid = shouldAskForGiftAidPermission {
            if(!shouldShowGiftAid) {
                giftAidSwitch.setOn(uExt!.GiftAidEnabled, animated: false)
                previousStateGiftAid = giftAidSwitch.isOn
            }
        }
        
        lblSettings.text = NSLocalizedString("GiftAid_Setting", comment:"")
        lblInfo.text = NSLocalizedString("GiftAid_Info", comment: "")
        lblHeaderDisclaimer.text = NSLocalizedString("GiftAid_HeaderDisclaimer", comment:"")
        lblBodyDisclaimer.text = NSLocalizedString("GiftAid_BodyDisclaimer", comment: "")
        btnSave.setTitle(NSLocalizedString("Save", comment:""), for: .normal)
        
        btnSave.accessibilityLabel = NSLocalizedString("Save", comment: "")
        
        if(comingFromRegistration){
            navigationItem.leftBarButtonItem?.isEnabled = false
            navigationItem.leftBarButtonItem?.image = nil
        }
        
        navigationItem.leftBarButtonItem?.action = #selector(showAlertPersonalInfo)
        navigationItem.rightBarButtonItem?.accessibilityLabel = NSLocalizedString("MoreInfo", comment: "")
    }
    
    override func viewDidLayoutSubviews() {
        let calcHeight = scrollView.subviews[0].subviews[0].frame.size.height +
                         scrollView.subviews[0].subviews[1].frame.size.height +
                         scrollView.subviews[0].subviews[2].frame.size.height + 50
        scrollView.contentSize =  CGSize(width: scrollView.subviews[0].frame.size.width,
                                         height: calcHeight)
    }
    
    @objc func showAlertPersonalInfo() {
        if previousStateGiftAid != giftAidSwitch.isOn {
            showAlert(title: NSLocalizedString("ImportantMessage", comment: ""),
                      message: NSLocalizedString("GiftAidUnsavedChanges", comment: ""),
                      action1: UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .default, handler: { action in
                        self.navigationController?.popViewController(animated: true)
                      }),
                      action2: UIAlertAction(title: NSLocalizedString("Back", comment: ""), style: .default, handler: { action in }) )
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
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
    
    @IBAction func saveAction(_ sender: Any) {
        self.endEditing()
        NavigationManager.shared.reAuthenticateIfNeeded(context: self, completion: {
            self.showLoader()
            if var userExt = self.uExt {
                userExt.GiftAidEnabled = self.giftAidSwitch.isOn
                self.loginManager.changeGiftAidEnabled(giftaidEnabled: userExt.GiftAidEnabled, completionHandler: {(success) in
                    DispatchQueue.main.async {
                        self.hideLoader()
                    }
                    if success {
                        Analytics.trackEvent("GIFTAID_CHANGED", withProperties:["state": (userExt.GiftAidEnabled).description])
                        Mixpanel.mainInstance().track(event: "GIFTAID_CHANGED", properties: ["state": (userExt.GiftAidEnabled).description])
                        DispatchQueue.main.async {
                            if(self.comingFromRegistration){
                                let vc = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "FinalRegistrationViewController") as! FinalRegistrationViewController
                                
                                    self.showAlert(title: NSLocalizedString("ImportantMessage", comment: ""),
                                                   message: NSLocalizedString("GiftAidChangeLater", comment: ""),
                                                   action1: UIAlertAction(title: NSLocalizedString("GotIt", comment: ""), style: .default, handler: { action in
                                                    
                                                    self.navigationController!.pushViewController(vc, animated: true)
                                                   }),
                                                   action2: nil )
                            } else {
                                self.dismiss(animated: true, completion: nil)
                            }
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
        })
    }
    
    func showAlert(title:String, message:String, action1: UIAlertAction, action2: UIAlertAction?) {
            let alert = UIAlertController(
                title: NSLocalizedString(title, comment: ""),
                message: NSLocalizedString(message, comment: ""),
                preferredStyle: UIAlertController.Style.alert)
            alert.addAction(action1)
            if let _action2 = action2 {
                    alert.addAction(_action2)
            }
            present(alert, animated: true, completion: nil)
    }
}
