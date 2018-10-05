//
//  BacsDetailViewController.swift
//  ios
//
//  Created by Lennie Stockman on 29/08/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit
import SVProgressHUD

class BacsDetailViewController: UIViewController {

    @IBOutlet var done: CustomButton!
    @IBOutlet var readGuarantee: CustomButton!
    @IBOutlet var personalInformationText: UILabel!
    @IBOutlet var personalDetailText: UILabel!
    var userExtension: LMUserExt!
    override func viewDidLoad() {
        super.viewDidLoad()
        let country = AppConstants.countries.first { (country) -> Bool in
            return country.shortName == userExtension.Country
        }
        
        title = NSLocalizedString("BacsVerifyTitle", comment: "")
        readGuarantee.setTitle(NSLocalizedString("BacsReadDDGuarantee", comment: ""), for: UIControlState.normal)
        done.setTitle(NSLocalizedString("Continue", comment: ""), for: UIControlState.normal)
        personalInformationText.text = NSLocalizedString("BacsVerifyBodyDetails", comment: "")
            .replacingOccurrences(of: "{0}", with: "\(userExtension.FirstName) \(userExtension.LastName)")
            .replacingOccurrences(of: "{1}", with: "\(userExtension.Address), \(userExtension.PostalCode) \(userExtension.City) \(country?.name ?? "undefined")")
            .replacingOccurrences(of: "{2}", with: userExtension.Email)
            .replacingOccurrences(of: "{3}", with: userExtension.SortCode!)
            .replacingOccurrences(of: "{4}", with: userExtension.AccountNumber!)
        personalDetailText.text = NSLocalizedString("BacsVerifyBody", comment: "")
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func readDirectDebitGuarantee(_ sender: Any) {
        let vc = UIStoryboard(name: "BACS", bundle: nil).instantiateViewController(withIdentifier: "BacsInfoViewController") as! BacsInfoViewController
        vc.title = NSLocalizedString("BacsDDGuaranteeTitle", comment: "")
        vc.bodyText = NSLocalizedString("BacsDDGuarantee", comment: "")
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        if NavigationManager.shared.hasInternetConnection(context: self) {
            let signatory = Signatory(givenName: userExtension.FirstName, familyName: userExtension.LastName, iban: nil, sortCode: userExtension.SortCode, accountNumber: userExtension.AccountNumber, email: userExtension.Email, telephone: userExtension.PhoneNumber, city: userExtension.City, country: userExtension.Country, postalCode: userExtension.PostalCode, street: userExtension.Address)
            let mandate = Mandate(signatory: signatory)
            SVProgressHUD.show()
            LoginManager.shared.requestMandateUrl(mandate: mandate, completionHandler: { (response) in
                SVProgressHUD.dismiss()
                if let r = response, r.status == .ok {
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
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
        }
    }
    @IBAction func goBack(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
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
