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
import AppCenterAnalytics

class ScanViewController: BaseScanViewController {
    @IBOutlet weak var backBtn: UIBarButtonItem!
    private var log = LogService.shared
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet var gif: UIImageView!
    @IBOutlet var titleText: UILabel!
    @IBOutlet var bodyText: UILabel!
    @IBOutlet var btnGive: CustomButton!
    @IBOutlet var btnGiveDifferent: CustomButton!
    
    private var overlayTask: DispatchWorkItem?
    private var bluetoothMessage: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MSAnalytics.trackEvent("GIVE_SCANNING_START")
        gif.loadGif(name: "givt_animation")
        bodyText.text = NSLocalizedString("MakeContact", comment: "Contact maken")
        btnGiveDifferent.setTitle(NSLocalizedString("GiveYetDifferently", comment: ""), for: .normal)
        btnGive.accessibilityLabel = NSLocalizedString("GiveDifferently", comment: "")
        titleText.text = NSLocalizedString("GiveWithYourPhone", comment: "")
        backBtn.accessibilityLabel = NSLocalizedString("Back", comment: "")
        btnGive.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

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
    }
    
    @IBAction func giveManually(_ sender: Any) {
        if let nameSpace = GivtManager.shared.bestBeacon?.namespace {
            GivtManager.shared.giveManually(antennaId: nameSpace)
        }
        MSAnalytics.trackEvent("GIVE_TO_SUGGESTION")

    }
    
    @objc func startScanning() {
        GivtManager.shared.startScanning(scanMode: .close)
    }

    func showGiveDifferentButton() {
        
        btnGiveDifferent.setTitle(NSLocalizedString("GiveYetDifferently", comment: ""), for: .normal)
        btnGiveDifferent.accessibilityLabel = NSLocalizedString("GiveYetDifferently", comment: "")

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(6)) {
            if let orgNamespace = GivtManager.shared.bestBeacon?.namespace, let orgName = GivtManager.shared.getOrganisationName(organisationNameSpace: orgNamespace) {
                self.btnGive.setTitle(NSLocalizedString("GiveToNearestBeacon", comment: "").replacingOccurrences(of: "{0}", with: orgName), for: .normal)
                self.btnGive.accessibilityLabel = self.btnGive.titleLabel?.text
                self.btnGive.titleLabel?.adjustsFontSizeToFitWidth = true
                self.btnGiveDifferent.setTitle(NSLocalizedString("GiveYetDifferently", comment: ""), for: .normal)
                self.btnGive.isHidden = false
                self.btnGiveDifferent.isHidden = false
            } else {
                self.btnGiveDifferent.setTitle(NSLocalizedString("GiveDifferently", comment: ""), for: .normal)
                self.btnGiveDifferent.accessibilityLabel = self.btnGiveDifferent.titleLabel?.text
                // Show only give different
                self.btnGiveDifferent.setBackgroundColor(color: #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1),forState: .normal)
                self.btnGiveDifferent.setTitleColor(.white, for: .normal)
                self.btnGiveDifferent.isHidden = false            }
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
        MSAnalytics.trackEvent("GIVE_FROM_LIST")

        btnGive.isEnabled = false
        GivtManager.shared.stopScanning()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SelectOrgViewController") as! SelectOrgViewController
        vc.cameFromScan = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
