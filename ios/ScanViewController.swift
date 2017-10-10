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
    
    func onGivtProcessed(transactions: [Transaction]) {
        var trs = [NSDictionary]()
        for tr in transactions {
            trs.append(["Amount" : tr.amount,"CollectId" : tr.collectId, "Timestamp" : tr.timeStamp, "BeaconId" : tr.beaconId])
        }
        var parameters = [NSDictionary]()
        parameters.append(["amountLimit" : 0,
                          "message" : NSLocalizedString("Safari_GivtTransaction", comment: ""),
                          "GUID" : "52435d45-042e-4ca0-b734-aa592d882fd3",
                          "urlPart" : "store",
                          "givtObj" : trs,
                          "apiUrl" : "https://givtapidebug.azurewebsites.net/",
                          "lastDigits" : "XXXXXXXXXXXXXXX7061",
                          "organisation" : "Bjornkerk",
                          "mandatePopup" : "",
                          "spUrl" : ""])
        
        
        guard let jsonParameters = try? JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            return
        }
        print(jsonParameters.description)
        let plainTextBytes = jsonParameters.base64EncodedString()
        let formatted = String(format: "https://givtapidebug.azurewebsites.net/givtapp4.html?msg=%@", plainTextBytes);
        self.showWebsite(url: formatted)

        /*
            let alert = UIAlertController(title: "Hey Gulle gever", message: "wacht es effe 30 seconde jo", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                self.popToRoot(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
         */
        
    }
    
    func showWebsite(url: String){
        let url = URL(string: url)!
        let webVC = SFSafariViewController(url: url)
        webVC.delegate = self
        webVC.preferredBarTintColor = UIColor.init(red: 24, green: 24, blue: 24)
        
        self.navigationController?.present(webVC, animated: true) {
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        gif.loadGif(name: "givt_animation")
        bodyText.text = NSLocalizedString("MakeContact", comment: "Contact maken")
        btnGive.setTitle(NSLocalizedString("GiveDifferently", comment: ""), for: .normal)

        
    }
    
    func showBluetoothMessage() {
        let alert = UIAlertController(
            title: NSLocalizedString("SomethingWentWrong2", comment: ""),
            message: NSLocalizedString("BluetoothErrorMessage", comment: ""),
            preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("TurnOnBluetooth", comment: ""), style: .default, handler: { action in
            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { action in
            //push geeflimiet pagina
        }))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                NotificationCenter.default.addObserver(self, selector: #selector(showBluetoothMessage), name: Notification.Name("BluetoothIsOff"), object: nil)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        GivtService.sharedInstance.onGivtProcessed = self
        
        if(GivtService.sharedInstance.bluetoothEnabled){
            GivtService.sharedInstance.startScanning()
        }
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
        NotificationCenter.default.removeObserver(self, name: Notification.Name("BluetoothIsOff"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func popToRoot(animated: Bool) {
        self.navigationController?.popViewController(animated: animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

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
