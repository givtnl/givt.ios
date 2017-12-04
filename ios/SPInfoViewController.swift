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
    private var log = LogService.shared
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var headerText: UILabel!
    @IBOutlet var explanation: UILabel!
    @IBOutlet var btnNext: CustomButton!
    var hasBackButton = false
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
        if !hasBackButton {
            self.backButton.isEnabled = false
            self.backButton.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            self.backButton.image = UIImage()
        } else {
            self.backButton.isEnabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func next(_ sender: Any) {
        if !NavigationManager.shared.hasInternetConnection(context: self) {
            return
        }
        
        SVProgressHUD.show()
        let userInfo = UserDefaults.standard.userExt!
        let signatory = Signatory(givenName: userInfo.firstName, familyName: userInfo.lastName, iban: userInfo.iban, email: userInfo.email, telephone: userInfo.mobileNumber, city: userInfo.city, country: userInfo.countryCode, postalCode: userInfo.postalCode, street: userInfo.address)
        let mandate = Mandate(signatory: signatory)
        LoginManager.shared.requestMandateUrl(mandate: mandate, completionHandler: { slimPayUrl in
            if slimPayUrl == "" {
                self.log.warning(message: "Mandate url is empty, what is going on?")
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: NSLocalizedString("NotificationTitle", comment: ""), message: NSLocalizedString("RequestMandateFailed", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Next", comment: ""), style: .cancel, handler: { (action) in
                    self.dismiss(animated: true, completion: {})
                }))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: {})
                }
                
            } else {
                self.log.info(message: "Mandate flow will now start")
                DispatchQueue.main.async {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SPWebViewController") as! SPWebViewController
                    vc.url = slimPayUrl
                    self.show(vc, sender: nil)
                }
            }
            
        })
        
    }

    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
