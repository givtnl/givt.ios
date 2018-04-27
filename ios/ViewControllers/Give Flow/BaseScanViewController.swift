//
//  BaseScanViewController.swift
//  ios
//
//  Created by Lennie Stockman on 2/01/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit
import SVProgressHUD

class BaseScanViewController: UIViewController, GivtProcessedProtocol {
    private var log = LogService.shared
    private var organisation = ""
    private var bestBeacon = BestBeacon()
    
    fileprivate func popToRootWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            if let amountVC = self.navigationController?.childViewControllers[0] as? AmountViewController {
                amountVC.reset()
            }
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onGivtProcessed(transactions: [Transaction]) {
        SVProgressHUD.dismiss()
        organisation = GivtService.shared.lastGivtOrg
        bestBeacon = GivtService.shared.getBestBeacon
        var trs = [NSDictionary]()
        for tr in transactions {
            trs.append(["Amount" : tr.amount,"CollectId" : tr.collectId, "Timestamp" : tr.timeStamp, "BeaconId" : tr.beaconId])
        }
        
        var canShare = false
        if let beaconId = GivtService.shared.getBestBeacon.beaconId, !beaconId.substring(16..<19).matches("c[0-9]|d[be]") {
            canShare = true
        }
        
        UserDefaults.standard.lastGivtToOrganisation = bestBeacon.organisation
        
        
        shouldShowMandate { (url) in
            var message = NSLocalizedString("SafariGiving", comment: "")
            if url == "" {
                //temp or has signed mandate
                if !self.organisation.isEmpty {
                    message = NSLocalizedString("SafariGivingToOrganisation", comment: "").replacingOccurrences(of:"{0}", with: self.organisation)
                }
            } else {
                message = NSLocalizedString("Safari_GivtTransaction", comment: "")
            }
            var parameters: [String: Any]
            parameters = ["Collect" : NSLocalizedString("Collect", comment: ""),
                          "AreYouSureToCancelGivts" :  NSLocalizedString("CancelGiftAlertMessage", comment: ""),
                          "ConfirmBtn" : url.count > 0 ? NSLocalizedString("Confirm", comment: "") : NSLocalizedString("Next", comment: ""),
                          "Cancel": NSLocalizedString("Cancel", comment: ""),
                          "SlimPayInformation": NSLocalizedString("SlimPayInformation", comment: ""),
                          "SlimPayInformationPart2" : NSLocalizedString("SlimPayInformationPart2", comment: ""),
                          "message" : message,
                          "Close": NSLocalizedString("Close", comment: ""),
                          "ShareGivt" : NSLocalizedString("ShareTheGivtButton", comment: ""),
                          "Thanks": NSLocalizedString("GivtIsBeingProcessed", comment: "").replacingOccurrences(of: "{0}", with: self.organisation),
                          "YesSuccess": NSLocalizedString("YesSuccess", comment: ""),
                          "GUID" : UserDefaults.standard.userExt!.guid,
                          "givtObj" : trs,
                          "apiUrl" : AppConstants.apiUri + "/",
                          "organisation" : self.organisation,
                          "spUrl" : url,
                          "canShare" : canShare]
        
            parameters["nativeAppScheme"] = AppConstants.appScheme
            parameters["urlPart"] = AppConstants.returnUrlDir
            
            guard let jsonParameters = try? JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted) else {
                return
            }
            
            print(jsonParameters.description)
            let plainTextBytes = jsonParameters.base64EncodedString()
            let formatted = String(format: AppConstants.apiUri + "/confirm.html?msg=%@", plainTextBytes);
            self.showWebsite(url: formatted)
        }
    }
    
    func shouldShowMandate(callback: @escaping (String) -> Void) {
        
        let userInfo = UserDefaults.standard.userExt!
        var country = ""
        if let idx = Int(userInfo.countryCode) {
            country = AppConstants.countries[idx].shortName
        } else {
            country = userInfo.countryCode
        }
        
        if userInfo.iban == AppConstants.tempIban || UserDefaults.standard.mandateSigned == true {
            print("not showing mandate")
            callback("")
            return
        }
        
        SVProgressHUD.show()
        let signatory = Signatory(givenName: userInfo.firstName, familyName: userInfo.lastName, iban: userInfo.iban, email: userInfo.email, telephone: userInfo.mobileNumber, city: userInfo.city, country: country, postalCode: userInfo.postalCode, street: userInfo.address)
        let mandate = Mandate(signatory: signatory)
        LoginManager.shared.requestMandateUrl(mandate: mandate, completionHandler: { slimPayUrl in
            SVProgressHUD.dismiss()
            if let url = slimPayUrl {
                callback(url)
            } else {
                callback("")
            }
        })
    }
    
    func showWebsite(url: String){
        if !AppServices.shared.connectedToNetwork() {
            self.log.info(message: "User gave offline")
            DispatchQueue.main.async {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScanCompleteViewController") as! ScanCompleteViewController
                vc.organisation = self.organisation
                vc.bestBeacon = self.bestBeacon
                self.show(vc, sender: self)
            }
            return
        }
        
        guard let url = URL(string: url) else {
            return //be safe
        }
        
        self.log.info(message: "Going to safari")
        if #available(iOS 10.0, *) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:], completionHandler: { (status) in
                    self.popToRootWithDelay()
                })
            }
        } else {
            DispatchQueue.main.async {
                if(UIApplication.shared.openURL(url)) {
                    self.popToRootWithDelay()
                }
            }
        }
    }
    
    func giveManually(antennaID: String) {
        SVProgressHUD.show()
        GivtService.shared.giveManually(antennaId: antennaID, afterGivt: { (seconds, transactions) in
            SVProgressHUD.dismiss()
            if seconds > 0 {
                LogService.shared.info(message: "Celebrating wiiehoeeew")
                DispatchQueue.main.async {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "YayController") as! CelebrateViewController
                    vc.secondsLeft = seconds
                    vc.transactions = transactions
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
        })
    }
    
    
}
