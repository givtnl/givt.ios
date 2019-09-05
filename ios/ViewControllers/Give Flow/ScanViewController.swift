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
    @IBOutlet var btnGiveDifferent: CustomButton!
    
    private var giveDifferentlyShowcase: MaterialShowcase?
    private var overlayTask: DispatchWorkItem?
    private var bluetoothMessage: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gif.loadGif(name: "givt_animation")
        bodyText.text = NSLocalizedString("MakeContact", comment: "Contact maken")
        btnGive.setTitle(NSLocalizedString("GiveDifferently", comment: ""), for: .normal)
        btnGiveDifferent.setTitle(NSLocalizedString("GiveYetDifferently", comment: ""), for: .normal)
        btnGive.accessibilityLabel = NSLocalizedString("GiveDifferently", comment: "")
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
        
        if GivtManager.shared.getBluetoothState(currentView: self.view) == .enabled || TARGET_OS_SIMULATOR != 0 {
            startScanning()
        } else if GivtManager.shared.getBluetoothState(currentView: self.view) == .disabled {
            showBluetoothMessage()
        }

        showGiveDifferentButton()
        addOverlay()
    }
    
    @IBAction func giveManually(_ sender: Any) {
        if let nameSpace = GivtManager.shared.bestBeacon?.namespace {
            GivtManager.shared.giveManually(antennaId: nameSpace)
        }
    }
    
    @objc func startScanning() {
        GivtManager.shared.startScanning(scanMode: .close)
    }

    func addOverlay() {
        overlayTask = DispatchWorkItem {
            self.showGiveDifferentlyShowcase()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(8), execute: overlayTask!)
    }
    func showGiveDifferentButton() {
        
        btnGiveDifferent.setTitle(NSLocalizedString("GiveDifferently", comment: ""), for: .normal)
        btnGiveDifferent.accessibilityLabel = NSLocalizedString("GiveDifferently", comment: "")

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(6)) {
            if let orgNamespace = GivtManager.shared.bestBeacon?.namespace, let orgName = GivtManager.shared.getOrganisationName(organisationNameSpace: orgNamespace) {
                self.btnGive.setTitle(NSLocalizedString("GiveToNearestBeacon", comment: "").replacingOccurrences(of: "{0}", with: orgName), for: .normal)
                self.btnGive.titleLabel?.adjustsFontSizeToFitWidth = true
                self.btnGiveDifferent.setTitle(NSLocalizedString("GiveYetDifferently", comment: ""), for: .normal)
                self.btnGive.isHidden = false
                self.btnGiveDifferent.isHidden = false
            } else {
                // Show only give different
                self.btnGiveDifferent.setBackgroundColor(color: #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1),forState: .normal)
                self.btnGiveDifferent.setTitleColor(.white, for: .normal)
                self.btnGiveDifferent.isHidden = false            }
        }
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
        navigationItem.accessibilityLabel = NSLocalizedString("ProgressBarStepThree", comment: "")
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
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SelectOrgViewController") as! SelectOrgViewController
        vc.cameFromScan = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
