//
//  PermissionViewController.swift
//  ios
//
//  Created by Lennie Stockman on 31/10/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit
import UserNotifications

class PermissionViewController: UIViewController {

    @IBOutlet var btnNext: CustomButton!
    var hasBackButton: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        btnNext.setTitle(NSLocalizedString("PrepareIUnderstand", comment: ""), for: .normal)
        btnNext.accessibilityLabel = NSLocalizedString("PrepareIUnderstand", comment: "")
        titleLabel.text = NSLocalizedString("PrepareMobileTitle", comment: "")
        firstLabel.text = NSLocalizedString("PrepareMobileExplained", comment: "")
        secondLabel.text = NSLocalizedString("PrepareMobileSummary", comment: "")

        if !hasBackButton {
            self.backButton.isEnabled = false
            self.backButton.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            self.backButton.image = UIImage()
            
        }
    }
    
    @IBOutlet var backButton: UIBarButtonItem!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnNext(_ sender: Any) {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .badge]) { (granted, error) in
                self.determineNextScreen()
            }
        } else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            
            determineNextScreen()
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func determineNextScreen() {
        if (UserDefaults.standard.accountType == AccountType.bacs) {
            DispatchQueue.main.async {
                let vc = UIStoryboard(name: "BACS", bundle: nil).instantiateViewController(withIdentifier: "BacsSettingUpViewController") as! BacsSettingUpViewController
                self.show(vc, sender: nil)
            }
        } else {
            DispatchQueue.main.async {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SPInfoViewController") as! SPInfoViewController
                self.show(vc, sender: nil)
            }
        }
    }
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var firstLabel: UILabel!
    @IBOutlet var secondLabel: UILabel!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
