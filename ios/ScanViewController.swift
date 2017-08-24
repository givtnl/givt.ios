//
//  ScanViewController.swift
//  ios
//
//  Created by Lennie Stockman on 14/07/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import CoreBluetooth
import SafariServices

class ScanViewController: UIViewController, GivtProcessedProtocol {

    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet var gif: UIImageView!
    @IBOutlet var bodyText: UILabel!
    @IBOutlet var btnGive: CustomButton!
    
    var amount: Decimal! = 0
    
    func onGivtProcessed(status: Bool) {
        if(status){
            print("beacon detected")
            print("amount set: ", amount)
            let parameters = ["amountLimit" : 0,
                              "message" : "Testing purposes",
                              "GUID" : "52435d45-042e-4ca0-b734-aa592d882fd3",
                              "urlPart" : "store",
                              "givtObj" :
                                [
                                    ["Amount" : 5.0,"CollectId" : "1", "Timestamp" : "", "BeaconId" : "61f7ed0142450816db00"],
                                    ["Amount" : 10.0,"CollectId" : "2", "Timestamp" : "", "BeaconId" : "61f7ed0142450816db00"],
                                ],
                              "apiUrl" : "https://givtapidebug.azurewebsites.net/",
                              "lastDigits" : "XXXXXXXXXXXXXXX7061",
                              "organisation" : "Bjornkerk",
                              "mandatePopup" : "hellow",
                              "spUrl" : "test"] as [String : Any]
            
            guard let jsonParameters = try? JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted) else {
                return
            }
            print(jsonParameters.description)
            let plainTextBytes = jsonParameters.base64EncodedString()
            
            
            let bad = String(format: "https://givtapidebug.azurewebsites.net/givtapp4.html?msg=%@", plainTextBytes);
            
            self.showWebsite(url: bad)
        } else {
            let alert = UIAlertController(title: "Hey Gulle gever", message: "wacht es effe 30 seconde jo", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                self.popToRoot(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showWebsite(url: String){
        let url = URL(string: url)!
        let webVC = SFSafariViewController(url: url)
        webVC.delegate = self
        webVC.preferredBarTintColor = UIColor.init(red: 24, green: 24, blue: 24)
        
        self.present(webVC, animated: true) {
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        gif.loadGif(name: "givt_animation")
        bodyText.text = NSLocalizedString("MakeContact", comment: "Contact maken")
        btnGive.setTitle(NSLocalizedString("GiveDifferently", comment: ""), for: .normal)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        GivtService.sharedInstance.setAmount(amount: amount)
        GivtService.sharedInstance.onGivtProcessed = self
        
        if(GivtService.sharedInstance.bluetoothEnabled)!{
            GivtService.sharedInstance.startScanning()
        }

        
        /*
        
                if(GivtService.sharedInstance.bluetoothEnabled)!{
            GivtService.sharedInstance.startScanning()
        } else {
            //bluetooth is disabled!
        }*/
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 251, green: 251, blue: 251)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.isOpaque = false
        sideMenuController?.isLeftViewSwipeGestureDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        sideMenuController?.isLeftViewSwipeGestureDisabled = false
        GivtService.sharedInstance.centralManager.stopScan()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func popToRoot(animated: Bool) {
        self.navigationController?.popViewController(animated: animated)
    }
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}

extension ScanViewController : SFSafariViewControllerDelegate{
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("ik kom er in")
        var navStackArray : [AnyObject]! = self.navigationController!.viewControllers
        // insert vc2 at second last position
        let test = storyboard?.instantiateViewController(withIdentifier: "testView")

        navStackArray.insert(test!, at: navStackArray.count)
        self.navigationController!.setViewControllers(navStackArray as! [UIViewController], animated:false)

        //self.popToRoot(animated: false)
        UIApplication.shared.statusBarStyle = .default
    }


}
