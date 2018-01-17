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

class ScanViewController: BaseScanViewController {
    private var log = LogService.shared
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet var gif: UIImageView!
    @IBOutlet var bodyText: UILabel!
    @IBOutlet var btnGive: CustomButton!
    var overlayView: UIView?
    @IBOutlet var overlay: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        gif.loadGif(name: "givt_animation")
        bodyText.text = NSLocalizedString("MakeContact", comment: "Contact maken")
        btnGive.setTitle(NSLocalizedString("GiveDifferently", comment: ""), for: .normal)
    }
    
    @objc func showBluetoothMessage() {
        GivtService.shared.stopScanning()
        let alert = UIAlertController(
            title: NSLocalizedString("SomethingWentWrong2", comment: ""),
            message: NSLocalizedString("BluetoothErrorMessage", comment: "") + "\n\n" + NSLocalizedString("ExtraBluetoothText", comment: ""),
            preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("TurnOnBluetooth", comment: ""), style: .default, handler: { action in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
            } else {
                UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
            }
            
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { action in
            //push geeflimiet pagina
        }))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(showBluetoothMessage), name: Notification.Name("BluetoothIsOff"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startScanning), name: Notification.Name("BluetoothIsOn"), object: nil)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        GivtService.shared.delegate = self
        
        self.log.info(message: "Scanpage is now showing")
        
        if(GivtService.shared.bluetoothEnabled){
            GivtService.shared.startScanning()
        }

        addOverlay()
    }

    
    @objc func startScanning() {
        GivtService.shared.startScanning()
    }
    
    func addOverlay() {
        if UserDefaults.standard.hasTappedAwayGiveDiff {
            return
        }
        
        overlayView = UIView()
        overlayView?.backgroundColor = #colorLiteral(red: 0.9843137255, green: 0.9843137255, blue: 0.9843137255, alpha: 0.9)
        overlayView?.alpha = 0
        overlayView?.translatesAutoresizingMaskIntoConstraints = false
        UIApplication.shared.keyWindow?.addSubview(overlayView!)
        let mainView = UIApplication.shared.keyWindow!
        //menuView.isUserInteractionEnabled = false
        overlayView?.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        overlayView?.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        if #available(iOS 11.0, *) {
            overlayView?.bottomAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.bottomAnchor, constant: -84.0).isActive = true
        } else {
            overlayView?.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -84.0).isActive = true
        }
        overlayView?.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        
        
        
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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(7), execute: { () -> Void in
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.overlayView?.alpha = 1
            }, completion: { (status) -> Void in
                let tap = UITapGestureRecognizer()
                tap.addTarget(self, action: #selector(self.removeOverlay))
                self.overlayView?.addGestureRecognizer(tap)
            })
        })
    }
    
    @objc func removeOverlay() {
        overlayView?.isHidden = true
        if overlayView?.alpha == 1 {
            UserDefaults.standard.hasTappedAwayGiveDiff = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        navigationController?.navigationBar.isTranslucent = true
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GivtService.shared.delegate = nil
        GivtService.shared.stopScanning()
        self.navigationController?.isNavigationBarHidden = false

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
        //self.popToRoot(animated: false)
        UIApplication.shared.statusBarStyle = .default
    }
    
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        print("url loaded")
    }


}
