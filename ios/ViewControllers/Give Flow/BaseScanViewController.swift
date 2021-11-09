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
    var bluetoothAlert: UIAlertController?
    private var isBacs = false
    
    private var bluetoothAsked = false
    
    func didUpdateBluetoothState(bluetoothState: BluetoothState) {
        DispatchQueue.main.async {
            switch(bluetoothState)
            {
            case .enabled:
                self.bluetoothAlert?.dismiss(animated: true, completion: nil)
            case .unauthorized:
                self.showBluetoothMessage(type: .unauthorized)
            default:
                self.showBluetoothMessage()
            }
        }
    }
        
    func didDetectGivtLocation(orgName: String, identifier: String) {
        
    }
    
    func deniedBluetoothAccess() {
        preconditionFailure("This method must be overridden")
    }
    
    func showBluetoothMessage(type: BluetoothMessageType = .normal, after: (() -> ())? = nil) {
        if !bluetoothAsked {
            if type == .unauthorized {
                self.bluetoothAlert = UIAlertController(
                    title: NSLocalizedString("AuthoriseBluetooth", comment: ""),
                    message: NSLocalizedString("AuthoriseBluetoothErrorMessage" , comment: "") + "\n\n" + NSLocalizedString("AuthoriseBluetoothExtraText", comment: "") ,
                    preferredStyle: UIAlertController.Style.alert)
            } else {
                self.bluetoothAlert = UIAlertController(
                    title: NSLocalizedString("ActivateBluetooth", comment: ""),
                    message: NSLocalizedString("BluetoothErrorMessage" , comment: "") + "\n\n" + NSLocalizedString("ExtraBluetoothText", comment: ""),
                    preferredStyle: UIAlertController.Style.alert)
            }
            bluetoothAlert!.addAction(UIAlertAction(title: NSLocalizedString("BluetoothErrorMessageAction", comment: ""), style: .cancel, handler: { action in
                if let after = after {
                    after()
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        self.didUpdateBluetoothState(bluetoothState: GivtManager.shared.getBluetoothState())
                    }
                }
            }))
            bluetoothAlert!.addAction(UIAlertAction(title: NSLocalizedString("BluetoothErrorMessageCancel", comment: ""), style: .default, handler: { action in
                self.deniedBluetoothAccess()
            }))
            present(self.bluetoothAlert!, animated: true, completion: nil)
            bluetoothAsked = true
        }
    }
    
    fileprivate func popToRootWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            if let amountVC = self.navigationController?.children[0].children[0].children[0] as? AmountViewController {
                amountVC.clearAmounts()
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
    
    func onGivtProcessed(transactions: [Transaction], organisationName: String?, canShare: Bool) {
        SVProgressHUD.dismiss()
        var trs = [NSDictionary]()
        for tr in transactions {
            trs.append(["Amount" : tr.amount,"CollectId" : tr.collectId, "Timestamp" : tr.timeStamp, "BeaconId" : tr.beaconId])
        }
        
        let orgName = organisationName ?? ""

        UserDefaults.standard.lastGivtToOrganisationNamespace = GivtManager.shared.bestBeacon?.namespace
        UserDefaults.standard.lastGivtToOrganisationName = orgName
        
        shouldShowMandate { (url) in
            var message = NSLocalizedString("SafariGiving", comment: "")
            if url == "" {
                //temp or has signed mandate
                if !orgName.isEmpty {
                    message = NSLocalizedString("SafariGivingToOrganisation", comment: "").replacingOccurrences(of:"{0}", with: orgName)
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
                          "Thanks": NSLocalizedString("GivtIsBeingProcessed", comment: "").replacingOccurrences(of: "{0}", with: orgName),
                          "YesSuccess": NSLocalizedString("YesSuccess", comment: ""),
                          "GUID" : UserDefaults.standard.userExt!.guid,
                          "givtObj" : trs,
                          "apiUrl" : AppConstants.apiUri + "/",
                          "organisation" : orgName,
                          "spUrl" : url,
                          "canShare" : canShare]
        
            parameters["nativeAppScheme"] = AppConstants.appScheme
            parameters["urlPart"] = AppConstants.returnUrlDir
            parameters["currency"] = CurrencyHelper.shared.getCurrencySymbol()
            
            guard let jsonParameters = try? JSONSerialization.data(withJSONObject: parameters) else {
                return
            }
            
            print(jsonParameters.description)
            let plainTextBytes = jsonParameters.base64EncodedString()
            let formatted = String(format: AppConstants.apiUri + "/confirm.html?msg=%@", plainTextBytes);
            
            DispatchQueue.main.async {
                AppServices.shared.vibrate()
            }
            
            if !AppServices.shared.isServerReachable {
                self.log.info(message: "User gave offline")
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "ScanCompleteViewController") as! ScanCompleteViewController
                    vc.organisation = orgName
                    vc.canShare = canShare
                    self.show(vc, sender: self)
                }
                return
            } else {
                self.showWebsite(url: formatted)
            }
        }
    }
    
    func shouldShowMandate(callback: @escaping (String) -> Void) {
        if UserDefaults.standard.isTempUser || UserDefaults.standard.mandateSigned == true || !AppServices.shared.isServerReachable {
            print("not showing mandate")
            callback("")
            return
        }
        
        NavigationManager.shared.reAuthenticateIfNeeded(context: self) {
            SVProgressHUD.show()
            LoginManager.shared.getUserExt { (userExtension) in
                guard let userExtension = userExtension else {
                    SVProgressHUD.dismiss()
                    callback("")
                    return
                }
                
                if userExtension.AccountNumber != nil && userExtension.SortCode != nil {
                    self.isBacs = true
                    callback("")
                    SVProgressHUD.dismiss()
                    return
                }
                
                LoginManager.shared.registerMandate(completionHandler: { (response) in
                    SVProgressHUD.dismiss()
                    if let r = response {
                        if r.basicStatus == .ok {
                            callback(r.text ?? "")
                        } else {
                            callback("")
                        }
                    } else {
                        //no response?
                        callback("")
                    }
                })
            }
        }
    }
    
    func showWebsite(url: String){
        guard let url = URL(string: url) else {
            return //be safe
        }
        self.log.info(message: "Going to safari")
        DispatchQueue.main.async {
            if !NavigationHelper.openUrl(url: url, completion: { (status) in
                self.popToRootWithDelay()
            }) {
                self.popToRootWithDelay()
            }
        }
    }
    
    func giveManually(antennaID: String) {
        SVProgressHUD.show()
        GivtManager.shared.giveManually(antennaId: antennaID, afterGivt: { (seconds, queueSet, transactions, orgName) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            
            LogService.shared.info(message: "Celebrating wiiehoeeew")
            
            if (!queueSet && seconds < 0) {
                self.onGivtProcessed(transactions: transactions, organisationName: orgName, canShare: true)
                return
            }
            
            if (queueSet) {
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "CelebrationQueueVC") as! CelebrationQueueViewController
                    vc.transactions = transactions
                    vc.organisation = orgName
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "YayController") as! CelebrateViewController
                    vc.secondsLeft = seconds
                    vc.transactions = transactions
                    vc.organisation = orgName
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        })
    }
    
    
}
