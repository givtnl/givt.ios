//
//  EventViewController.swift
//  ios
//
//  Created by Lennie Stockman on 3/05/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit
import CoreLocation
import AudioToolbox

class EventViewController: BaseScanViewController {
    @IBOutlet var giveDifferently: CustomButton!
    private let _givtService = GivtService.shared
    private var isSuggestionShowing = false
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var imageV: UIImageView!
    private var countdownTimer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = NSLocalizedString("SearchingEventText", comment: "")
        giveDifferently.setTitle(NSLocalizedString("GiveDifferently", comment: ""), for: .normal)
        title = NSLocalizedString("SelectLocationContext", comment: "")
        // Do any additional setup after loading the view.
    }
    @IBOutlet var givyContstraint: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(startScanning), name: Notification.Name("BluetoothIsOn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDiscoverBeacon), name: Notification.Name("DidDiscoverBeacon"), object: nil)
        _givtService.delegate = self
        let bluetoothEnabled = _givtService.bluetoothEnabled
        let locationEnabled = AppServices.isLocationPermissionGranted()
        
        if !bluetoothEnabled && !locationEnabled { //if both disabled, show both after each other.
            showBluetoothMessage {
                self.showLocationMessage()
            }
        } else if !bluetoothEnabled { //only BL disabled
            showBluetoothMessage(after: {})
        } else if !locationEnabled { //only loc disabled
            showLocationMessage()
        }
        
        startScanning()
        
        givyContstraint.constant = 20
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.repeat, .autoreverse], animations: {
            self.view.layoutIfNeeded()
        }) { (done) in
        }

        startTimer()
        
        start20sTimer()
    }
    
    @objc func startScanning() {
        _givtService.startScanning(shouldNotify: true)
    }
    
    func showBluetoothMessage(after: @escaping () -> ()) {
        let alert = UIAlertController(
            title: NSLocalizedString("TurnOnBluetooth", comment: ""),
            message: NSLocalizedString("BluetoothErrorMessage", comment: "") + "\n\n" + NSLocalizedString("ExtraBluetoothText", comment: ""),
            preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("GotIt", comment: ""), style: .default, handler: { action in
            after()
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func showLocationMessage() {
        let alert = UIAlertController(title: NSLocalizedString("AllowGivtLocationTitle", comment: ""), message: NSLocalizedString("AllowGivtLocationMessage", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("GotIt", comment: ""), style: UIAlertActionStyle.default, handler: { (action) in
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func start20sTimer() {
        Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(after20s), userInfo: nil, repeats: false)
    }
    @IBAction func giveDifferently(_ sender: Any) {
        self.stopTimer()
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ManualGivingViewController") as! ManualGivingViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func after20s() {
        
        if let region = self._givtService.getGivtLocation() {
            self.foundRegion(region: region)
        }
        UIView.animate(withDuration: 0.3) {
            self.giveDifferently.isHidden = false
        }
    }
    
    private func startTimer() {
        _givtService.startLookingForGivtLocations()
        countdownTimer = Timer.scheduledTimer(timeInterval:
            6, target: self, selector: #selector(tickingClocks), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        countdownTimer?.invalidate()
    }
    
    @objc func tickingClocks() {
        self.stopTimer()
        GivtService.shared.stopScanning()
        GivtService.shared.stopLookingForGivtLocations()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if let region = self._givtService.getGivtLocation() {
                self.foundRegion(region: region)
            } else {
                self.startTimer()
            }
        }
    }
    
    private func foundRegion(region: GivtLocation) {
        if (self.navigationController?.visibleViewController as? EventSuggestionViewController) != nil {
            return
        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventSuggestionViewController") as! EventSuggestionViewController
        vc.providesPresentationContextTransitionStyle = true
        vc.definesPresentationContext = true
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        vc.organisation = region.organisationName
        vc.onClose = {
            self.startTimer()
        }
        vc.onSuccess = {
            self.giveManually(antennaID: region.beaconId)
        }
        AudioServicesPlayAlertSound(1519)
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("DidDiscoverBeacon"), object: nil)
        GivtService.shared.delegate = nil
        GivtService.shared.stopScanning()
        GivtService.shared.stopLookingForGivtLocations()
        self.stopTimer()
    }
    
    @objc func didDiscoverBeacon(notification: NSNotification) {
        GivtService.shared.stopScanning()
        GivtService.shared.stopLookingForGivtLocations()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            guard let orgName = self._givtService.getOrgName(orgNameSpace: self._givtService.getBestBeacon.namespace!) else {
                self._givtService.startScanning(shouldNotify: true)
                return
            }
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventSuggestionViewController") as! EventSuggestionViewController
            vc.providesPresentationContextTransitionStyle = true
            vc.definesPresentationContext = true
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            vc.organisation = orgName
            vc.onClose = {
                self._givtService.startScanning(shouldNotify: true)
            }
            vc.onSuccess = {
                self.giveManually(antennaID: self._givtService.getBestBeacon.beaconId!)
            }
            AudioServicesPlayAlertSound(1519)
            self.present(vc, animated: true, completion: nil)
        }

    }
 
}
