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
    var overlayView: UIView?
    @IBOutlet var overlay: UIView!
    func onGivtProcessed(transactions: [Transaction]) {
        var trs = [NSDictionary]()
        for tr in transactions {
            trs.append(["Amount" : tr.amount,"CollectId" : tr.collectId, "Timestamp" : tr.timeStamp, "BeaconId" : tr.beaconId])
        }

        var canShare = false
        if let beaconId = GivtService.shared.getBestBeacon.beaconId, !beaconId.substring(16..<19).matches("c[0-9]|d[be]") {
            canShare = true
        }
        
        var parameters: NSDictionary
        parameters = ["amountLimit" : 0,
                          "message" : NSLocalizedString("Safari_GivtTransaction", comment: ""),
                          "GUID" : "",
                          "urlPart" : "hockey",
                          "givtObj" : trs,
                          "apiUrl" : "https://givtapidebug.azurewebsites.net/",
                          "lastDigits" : "XXXXXXXXXXXXXXX7061",
                          "organisation" : GivtService.shared.lastGivtOrg,
                          "mandatePopup" : "",
                          "spUrl" : "",
                          "canShare" : canShare] as NSDictionary
        
        
        guard let jsonParameters = try? JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            return
        }
        
        print(jsonParameters.description)
        let plainTextBytes = jsonParameters.base64EncodedString()
        let formatted = String(format: "https://givtapidebug.azurewebsites.net/givtapp4.html?msg=%@", plainTextBytes);
        self.showWebsite(url: formatted)
    }
    
    fileprivate func popToRootWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    func showWebsite(url: String){
        guard let url = URL(string: url) else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: { (status) in
                self.popToRootWithDelay()
            })
        } else {
            if(UIApplication.shared.openURL(url)) {
                self.popToRootWithDelay()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        gif.loadGif(name: "givt_animation")
        bodyText.text = NSLocalizedString("MakeContact", comment: "Contact maken")
        btnGive.setTitle(NSLocalizedString("GiveDifferently", comment: ""), for: .normal)
    }
    
    @objc func showBluetoothMessage() {
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

        addOverlay()

        
        
    }
    
    func addOverlay() {
        if UserDefaults.standard.hasTappedAwayGiveDiff {
            return
        }
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(removeOverlay))
        
        overlayView = UIView()
        overlayView?.backgroundColor = #colorLiteral(red: 0.9843137255, green: 0.9843137255, blue: 0.9843137255, alpha: 0.9)
        overlayView?.alpha = 0
        overlayView?.translatesAutoresizingMaskIntoConstraints = false
        UIApplication.shared.keyWindow?.addSubview(overlayView!)
        let mainView = UIApplication.shared.keyWindow!
        //menuView.isUserInteractionEnabled = false
        overlayView?.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        overlayView?.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        overlayView?.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -84.0).isActive = true
        overlayView?.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        
        overlayView?.addGestureRecognizer(tap)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        overlayView?.addSubview(label)
        label.numberOfLines = 0
        label.leadingAnchor.constraint(equalTo: (overlayView?.leadingAnchor)!, constant: 20).isActive = true
        label.bottomAnchor.constraint(equalTo: (overlayView?.bottomAnchor)!, constant: 0 ).isActive = true
        label.trailingAnchor.constraint(equalTo: (overlayView?.trailingAnchor)!, constant: -20).isActive = true
        label.font = UIFont(name: "Avenir-Heavy", size: 16.0)
        label.text = NSLocalizedString("GiveDiffWalkthrough", comment: "")
        label.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        label.textAlignment = .center
    
        self.overlayView?.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 7.0, options: [], animations: {
            self.overlayView?.alpha = 1
        }) { (status) in
        //done
        }
    }
    
    func removeOverlay() {
        overlayView?.removeFromSuperview()

        if let isHidden = overlayView?.isHidden, !isHidden {
            overlayView?.isHidden = true
            UserDefaults.standard.hasTappedAwayGiveDiff = true
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
        removeOverlay()
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


        //self.popToRoot(animated: false)
        UIApplication.shared.statusBarStyle = .default
    }
    
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        print("url loaded")
    }


}
