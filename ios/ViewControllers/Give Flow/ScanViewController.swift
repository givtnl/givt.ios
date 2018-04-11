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
import MaterialShowcase

class ScanViewController: BaseScanViewController {
    private var log = LogService.shared
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet var gif: UIImageView!
    @IBOutlet var bodyText: UILabel!
    @IBOutlet var btnGive: CustomButton!
    private var giveDifferentlyShowcase: MaterialShowcase?

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
        btnGive.isEnabled = true
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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(7), execute: { () -> Void in
            self.showGiveDifferentlyShowcase()
        })
    }
    
    @objc func removeOverlay() {
        guard let showcase = self.giveDifferentlyShowcase else {
            return
        }
        
        showcase.completeShowcase()
        UserDefaults.standard.showcases.append(AppConstants.Showcase.giveDifferently.rawValue)
    }
    
    func showGiveDifferentlyShowcase() {
        if UserDefaults.standard.showcases.contains(AppConstants.Showcase.giveDifferently.rawValue) {
            return
        }
        self.giveDifferentlyShowcase = MaterialShowcase()
        
        self.giveDifferentlyShowcase!.primaryText = NSLocalizedString("GiveDiffWalkthrough", comment: "")
        self.giveDifferentlyShowcase!.secondaryText = NSLocalizedString("CancelFeatureMessage", comment: "")
        
        DispatchQueue.main.async {
            self.giveDifferentlyShowcase!.setTargetView(view: self.btnGive) // always required to set targetView
            self.giveDifferentlyShowcase?.shouldSetTintColor = false
            self.giveDifferentlyShowcase!.backgroundPromptColor = #colorLiteral(red: 0.3513332009, green: 0.3270585537, blue: 0.5397221446, alpha: 1)
            self.giveDifferentlyShowcase!.show(completion: nil)
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
        btnGive.isEnabled = false
        GivtService.shared.stopScanning()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ManualGivingViewController") as! ManualGivingViewController
        self.navigationController?.pushViewController(vc, animated: true)
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
