//
//  SPInfoViewController.swift
//  ios
//
//  Created by Lennie Stockman on 28/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import SVProgressHUD

class SPInfoViewController: UIViewController {

    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var headerText: UILabel!
    @IBOutlet var explanation: UILabel!
    @IBOutlet var btnNext: CustomButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.isEnabled = false
        headerText.text = NSLocalizedString("SlimPayInformation", comment: "")
        explanation.text = NSLocalizedString("SlimPayInformationPart2", comment: "")
        btnNext.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func next(_ sender: Any) {
        SVProgressHUD.show()
        var userInfo = UserDefaults.standard.userExt
        var signatory = Signatory(givenName: userInfo.firstName, familyName: userInfo.lastName, iban: userInfo.iban, email: userInfo.email, telephone: userInfo.mobileNumber, city: userInfo.city, country: userInfo.countryCode, postalCode: userInfo.postalCode, street: userInfo.address)
        var mandate = Mandate(signatory: signatory)
        LoginManager.shared.requestMandateUrl(mandate: mandate, completionHandler: { slimPayUrl in
            DispatchQueue.main.async {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SPWebViewController") as! SPWebViewController
                vc.url = slimPayUrl
                self.show(vc, sender: nil)
            }
        })
        
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
