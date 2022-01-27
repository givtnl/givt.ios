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
    private var log: LogService = LogService.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        let country = AppConstants.countries.first { (country) -> Bool in
            return country.shortName == userExtension.Country
        }
        
        title = NSLocalizedString("BacsVerifyTitle", comment: "")
        readGuarantee.setTitle(NSLocalizedString("BacsReadDDGuarantee", comment: ""), for: UIControl.State.normal)
        done.setTitle(NSLocalizedString("Continue", comment: ""), for: UIControl.State.normal)
        personalInformationText.text = NSLocalizedString("BacsVerifyBodyDetails", comment: "")
            .replacingOccurrences(of: "{0}", with: "\(userExtension.FirstName!) \(userExtension.LastName!)")
            .replacingOccurrences(of: "{1}", with: "\(userExtension.Address!), \(userExtension.PostalCode!) \(userExtension.City!) \(country?.name!)")
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
        (sender as! UIButton).isEnabled = false
        if NavigationManager.shared.hasInternetConnection(context: self) {
            SVProgressHUD.show()
            LoginManager.shared.registerMandate { (response) in
                SVProgressHUD.dismiss()
                if let r = response {
                    if(r.status == .ok){
                        LoginManager.shared.finishMandateSigning(completionHandler: { (done) in
                            print(done)
                        })
                        DispatchQueue.main.async {
                            let vc = UIStoryboard(name: "Personal", bundle: nil).instantiateViewController(withIdentifier: "GiftAidViewController") as! GiftAidViewController
                            vc.comingFromRegistration = true
                            vc.uExt = self.userExtension
                            self.navigationController!.pushViewController(vc, animated: true)
                        }
                    } else {
                        let alert = UIAlertController(title: NSLocalizedString("RequestFailed", comment: ""), message: NSLocalizedString("RequestMandateFailed", comment: ""), preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (actions) in
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: nil)
                                NavigationManager.shared.loadMainPage(animated: false)
                            }
                        }))
                        if (r.statusCode == 409) {
                            alert.title = "RequestFailed".localized
                            alert.message = "DuplicateAccountOrganisationMessage".localized
                        } else if let data = r.data {
                            do {
                                let parsedData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                                if let additionalInformation = parsedData["AdditionalInformation"] as? Dictionary<String, Any>,
                                    let errorTerm = additionalInformation["errorTerm"] as? String {
                                    alert.title = NSLocalizedString("DDIFailedTitle", comment: "")
                                    alert.message = NSLocalizedString(errorTerm, comment: "")
                                } else if let parsedCode = parsedData["Code"] as? Int {
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
            }
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
