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
        var parameters: NSDictionary
        parameters = ["amountLimit" : 0,
                          "message" : NSLocalizedString("Safari_GivtTransaction", comment: ""),
                          "GUID" : "",
                          "urlPart" : "hockey",
                          "givtObj" : trs,
                          "apiUrl" : "https://givtapidebug.azurewebsites.net/",
                          "lastDigits" : "XXXXXXXXXXXXXXX7061",
                          "organisation" : "Bjornkerk",
                          "mandatePopup" : "",
                          "spUrl" : ""] as NSDictionary
        
        
        guard let jsonParameters = try? JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            return
        }
        
        print(jsonParameters.description)
        let plainTextBytes = jsonParameters.base64EncodedString()
        let formatted = String(format: "https://givtapidebug.azurewebsites.net/givtapp4.html?msg=%@", plainTextBytes);
        self.showWebsite(url: formatted)
    }
    
    func showWebsite(url: String){
        let url = URL(string: url)!
        let webVC = SFSafariViewController(url: url)
        webVC.delegate = self
        DispatchQueue.main.async {
            webVC.preferredBarTintColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
            webVC.preferredControlTintColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        }
        self.navigationController?.present(webVC, animated: true) {
            UIApplication.shared.statusBarStyle = .default
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
        GivtService.shared.onGivtProcessed = self
        
        if(GivtService.shared.bluetoothEnabled){
            GivtService.shared.startScanning()
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
        GivtService.shared.centralManager.stopScan()
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
    
    @IBAction func giveDifferently(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ManualGivingViewController") as! ManualGivingViewController
        self.show(vc, sender: nil)
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
    
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        print("url loaded")
    }


}
