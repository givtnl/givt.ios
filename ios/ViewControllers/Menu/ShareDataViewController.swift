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

class ShareDataViewController: UIViewController {
    
    var uExt: LMUserExt?
    
    @IBOutlet weak var shareDataSwitch: UISwitch!
    @IBOutlet weak var lblSettings: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblHeaderDisclaimer: UILabel!
    @IBOutlet weak var lblBodyDisclaimer: UILabel!
    @IBOutlet weak var btnSave: CustomButton!
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        NavigationManager.shared.reAuthenticateIfNeeded(context: self, completion: {
            self.showLoader()
            try? Mediater.shared.sendAsync(request: GetShareDataQuery(), completion: { res in
                self.shareDataSwitch.isOn = res
                self.hideLoader()
            })
        })
    }
    override func viewDidLayoutSubviews() {
        let calcHeight = scrollView.subviews[0].subviews[0].frame.size.height +
                         scrollView.subviews[0].subviews[1].frame.size.height + 50
        scrollView.contentSize =  CGSize(width: scrollView.subviews[0].frame.size.width,
                                         height: calcHeight)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        self.endEditing()
        NavigationManager.shared.reAuthenticateIfNeeded(context: self, completion: {
            self.showLoader()
                try? Mediater.shared.sendAsync(request: PutShareDataCommand(shareData: self.shareDataSwitch.isOn)) { res in
                    self.hideLoader()
                    if res {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.showAlert(
                            title: NSLocalizedString("SomethingWentWrong", comment: ""),
                            message: NSLocalizedString("UpdatePersonalInfoError", comment: ""),
                            action1: UIAlertAction(title: NSLocalizedString("GotIt", comment: ""), style: .default, handler: { action in
                            }),
                            action2: nil
                        )
                    }
                    
                }
        
//                else {

//                }
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
