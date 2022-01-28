//
//  BacsSettingUpViewController.swift
//  ios
//
//  Created by Lennie Stockman on 29/08/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit
import SVProgressHUD
import AppCenterAnalytics
import Mixpanel

class BacsSettingUpViewController: UIViewController {

    @IBOutlet var bodyText: UILabel!
    @IBOutlet var nextButton: CustomButton!
    @IBOutlet var advanceNoticeLabel: UILabel!
    @IBAction func giveConsent(_ sender: Any) {
        let btn = sender as! UIButton
        btn.isSelected = !btn.isSelected
        nextButton.isEnabled = btn.isSelected
    }
    private var helpViewController = UIStoryboard(name: "BACS", bundle: nil).instantiateViewController(withIdentifier: "BacsInfoViewController") as! BacsInfoViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.trackEvent("User started BACS mandate flow")
        Mixpanel.mainInstance().track(event: "User started BACS mandate flow")

        self.navigationController?.removeLogo()
        title = NSLocalizedString("BacsSetupTitle", comment: "")
        bodyText.text = NSLocalizedString("BacsSetupBody", comment: "")
        nextButton.setTitle(NSLocalizedString("Continue", comment: ""), for: .normal)
        nextButton.setBackgroundColor(color: UIColor.init(rgb: 0xE3E2E7), forState: .disabled)
        
        let attachment:NSTextAttachment = NSTextAttachment()
        attachment.image = #imageLiteral(resourceName: "littleinfo.png")
        attachment.bounds = CGRect(x: 0, y: -4, width: (attachment.image?.size.width)!, height: (attachment.image?.size.height)!)
        let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
        let myString:NSMutableAttributedString = NSMutableAttributedString(string: NSLocalizedString("BacsUnderstoodNotice", comment: "") + " ")
        myString.append(attachmentString)
        
        advanceNoticeLabel.attributedText = myString
        let tap = UITapGestureRecognizer(target: self, action: #selector(openAdvanceNotice))
        advanceNoticeLabel.addGestureRecognizer(tap)
        advanceNoticeLabel.isUserInteractionEnabled = true
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.native)
        SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.native)
    }
    
    @objc func openAdvanceNotice() {
        helpViewController.title = NSLocalizedString("BacsAdvanceNoticeTitle", comment: "")
        helpViewController.bodyText = NSLocalizedString("BacsAdvanceNotice", comment: "")
        self.present(helpViewController, animated: true, completion: nil)
    }
    @IBAction func openHelp(_ sender: Any) {
        helpViewController.title = NSLocalizedString("BacsHelpTitle", comment: "")
        helpViewController.bodyText = NSLocalizedString("BacsHelpBody", comment: "")
        self.present(helpViewController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    @IBAction func next(_ sender: Any) {
        if NavigationManager.shared.hasInternetConnection(context: self) {
            NavigationManager.shared.reAuthenticateIfNeeded(context: self) {
                SVProgressHUD.show()
                LoginManager.shared.getUserExt(completion: { (userExt) in
                    SVProgressHUD.dismiss()
                    guard let userExt = userExt else {
                        let alert = UIAlertController(title: NSLocalizedString("RequestFailed", comment: ""), message: NSLocalizedString("CantFetchPersonalInformation", comment: ""), preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                        }))
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: {})
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BacsDetailViewController") as! BacsDetailViewController
                        vc.userExtension = userExt
                        self.navigationController!.pushViewController(vc, animated: true)
                    }
                })
            }
        }
    }
    
}
