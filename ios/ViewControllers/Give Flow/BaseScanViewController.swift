//
//  BaseScanViewController.swift
//  ios
//
//  Created by Lennie Stockman on 2/01/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit

class BaseScanViewController: UIViewController, GivtProcessedProtocol {
    private var log = LogService.shared
    
    fileprivate func popToRootWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onGivtProcessed(transactions: [Transaction]) {
        var trs = [NSDictionary]()
        for tr in transactions {
            trs.append(["Amount" : tr.amount,"CollectId" : tr.collectId, "Timestamp" : tr.timeStamp, "BeaconId" : tr.beaconId])
        }
        
        var canShare = false
        if let beaconId = GivtService.shared.getBestBeacon.beaconId, !beaconId.substring(16..<19).matches("c[0-9]|d[be]") {
            canShare = true
        }
        
        
        var parameters: [String: Any]
        parameters = ["amountLimit" : 0,
                      "message" : NSLocalizedString("Safari_GivtTransaction", comment: ""),
                      "GUID" : UserDefaults.standard.userExt!.guid,
                      "urlPart" : "native",
                      "givtObj" : trs,
                      "apiUrl" : AppConstants.apiUri + "/",
                      "lastDigits" : "XXXXXXXXXXXXXXX7061",
                      "organisation" : GivtService.shared.lastGivtOrg,
                      "mandatePopup" : "",
                      "spUrl" : "",
                      "canShare" : canShare]
        
        #if DEBUG
            parameters["nativeAppScheme"] = "givtnd://"
        #else
            parameters["nativeAppScheme"] = "givtn://"
        #endif
        
        
        guard let jsonParameters = try? JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            return
        }
        
        print(jsonParameters.description)
        let plainTextBytes = jsonParameters.base64EncodedString()
        let formatted = String(format: AppConstants.apiUri + "/givtapp4.html?msg=%@", plainTextBytes);
        self.showWebsite(url: formatted)
    }
    
    func showWebsite(url: String){
        if !AppServices.shared.connectedToNetwork() {
            self.log.info(message: "User gave offline")
            DispatchQueue.main.async {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScanCompleteViewController") as! ScanCompleteViewController
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
}
