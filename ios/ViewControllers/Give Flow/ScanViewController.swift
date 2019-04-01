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
    @IBOutlet weak var backBtn: UIBarButtonItem!
    private var log = LogService.shared
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet var gif: UIImageView!
    @IBOutlet var titleText: UILabel!
    @IBOutlet var bodyText: UILabel!
    @IBOutlet var btnGive: CustomButton!
    private var giveDifferentlyShowcase: MaterialShowcase?
    private var overlayTask: DispatchWorkItem?
    private var bluetoothMessage: UIAlertController?
    override func viewDidLoad() {
        super.viewDidLoad()
        gif.loadGif(name: "givt_animation")
        bodyText.text = NSLocalizedString("MakeContact", comment: "Contact maken")
        btnGive.setTitle(NSLocalizedString("GiveDifferently", comment: ""), for: .normal)
        titleText.text = NSLocalizedString("GiveWithYourPhone", comment: "")
        backBtn.accessibilityLabel = NSLocalizedString("Back", comment: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        btnGive.isEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(startScanning), name: Notification.Name("BluetoothIsOn"), object: nil)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        GivtManager.shared.delegate = self
        
        self.log.info(message: "Scanpage is now showing")
        
        if(GivtManager.shared.isBluetoothEnabled || TARGET_OS_SIMULATOR != 0){
            startScanning()
        } else {
            showBluetoothMessage()
        }

        addOverlay()
    }
    
    @objc func startScanning() {
        GivtManager.shared.startScanning(scanMode: .close)
        
    }
    
    func addOverlay() {
        overlayTask = DispatchWorkItem {
            self.showGiveDifferentlyShowcase()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(7), execute: overlayTask!)
    }
    
    @objc func removeOverlay() {
        overlayTask?.cancel()
        guard let showcase = self.giveDifferentlyShowcase else {
            return
        }
        
        showcase.completeShowcase()
        UserDefaults.standard.showCasesByUserID.append(UserDefaults.Showcase.giveDifferently.rawValue)
    }
    
    func showGiveDifferentlyShowcase() {
        if UserDefaults.standard.showCasesByUserID.contains(UserDefaults.Showcase.giveDifferently.rawValue) {
            return
        }
        self.giveDifferentlyShowcase = MaterialShowcase()
        
        self.giveDifferentlyShowcase!.primaryText = NSLocalizedString("GiveDiffWalkthrough", comment: "")
        self.giveDifferentlyShowcase!.secondaryText = NSLocalizedString("CancelFeatureMessage", comment: "")
        
        let gesture = UISwipeGestureRecognizer(target: self, action:  #selector(self.removeOverlay))
        self.giveDifferentlyShowcase!.addGestureRecognizer(gesture)
        
        DispatchQueue.main.async {
            self.giveDifferentlyShowcase!.setTargetView(view: self.btnGive) // always required to set targetView
            self.giveDifferentlyShowcase?.shouldSetTintColor = false
            self.giveDifferentlyShowcase!.backgroundPromptColor = #colorLiteral(red: 0.3513332009, green: 0.3270585537, blue: 0.5397221446, alpha: 1)
            self.giveDifferentlyShowcase!.show(completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.titleView = UIImageView(image: UIImage(named: "pg_give_third"))
        navigationController?.navigationBar.backgroundColor = UIColor(rgb: 0xfbfbfb)
        navigationController?.navigationBar.isTranslucent = true
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        GivtManager.shared.delegate = nil
        GivtManager.shared.stopScanning()
        self.navigationController?.isNavigationBarHidden = false

        NotificationCenter.default.removeObserver(self, name: Notification.Name("BluetoothIsOff"), object: nil)
        removeOverlay()
        super.viewWillDisappear(animated)
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
        GivtManager.shared.stopScanning()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ManualGivingViewController") as! ManualGivingViewController
        vc.cameFromScan = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
