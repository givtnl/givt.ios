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
    var comingFromRegistration: Bool = false
        private var log: LogService = LogService.shared
    
    @IBOutlet weak var giftAidSwitch: UISwitch!
    @IBOutlet weak var lblSettings: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblHeaderDisclaimer: UILabel!
    @IBOutlet weak var lblBodyDisclaimer: UILabel!
    @IBOutlet weak var btnSave: CustomButton!
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
        
           if(comingFromRegistration){
                navigationItem.leftBarButtonItem?.isEnabled = false
                navigationItem.leftBarButtonItem?.image = nil
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
        if let userExt = uExt {
            self.loginManager.updateUser(uext: userExt, completionHandler: {(success) in
                if success {
                    DispatchQueue.main.async {
                        if(self.comingFromRegistration){
                            let vc = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "FinalRegistrationViewController") as! FinalRegistrationViewController
                            self.navigationController!.pushViewController(vc, animated: true)
                            
                            
                        } else {
                            self.navigationController?.popViewController(animated: true)
                            
                        }
                    }
                } else {
                    self.showSaveFailedError()
                }
            })
        }
    }
    private func showSaveFailedError() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: NSLocalizedString("SaveFailed", comment: ""), message: NSLocalizedString("UpdatePersonalInfoError", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
