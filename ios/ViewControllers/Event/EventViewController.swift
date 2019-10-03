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
import AppCenterAnalytics

enum GivingState: Int {
    case idle
    case alert
    case given
}

class EventViewController: BaseScanViewController {
    @IBOutlet var giveDifferently: CustomButton!
    private let givtManager = GivtManager.shared
    private var isSuggestionShowing = false
    @IBOutlet var mainTitle: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var imageV: UIImageView!
    private var countdownTimer: Timer?
    private var timer20S: Timer?
    
    private var shouldShowAfterBluetoothAlert: () -> Void = {}

    private var givingState: GivingState = .idle

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = NSLocalizedString("SearchingEventText", comment: "")
        giveDifferently.setTitle(NSLocalizedString("GiveDifferently", comment: ""), for: .normal)
        mainTitle.text = NSLocalizedString("SelectLocationContext", comment: "")
        self.givingState = .idle
    }
    
    @IBOutlet var givyContstraint: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.titleView = UIImageView(image: UIImage(named: "pg_give_third"))
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = true
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = false
        LogService.shared.info(message: "GIVE_LOCATION_START")
        MSAnalytics.trackEvent("GIVE_LOCATION_START")
    }
    
    override func didDetectGivtLocation(orgName: String, identifier: String) {
        DispatchQueue.main.async {
            if self.givingState == .idle {
                self.givingState = .alert
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventSuggestionViewController") as! EventSuggestionViewController
                vc.providesPresentationContextTransitionStyle = true
                vc.definesPresentationContext = true
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                vc.organisation = orgName
                vc.onClose = {
                    self.givingState = .idle
                }
                vc.onSuccess = {
                    self.givingState = .given
                    LogService.shared.info(message: "GIVE_LOCATION id: \(identifier)")
                    MSAnalytics.trackEvent("GIVE_LOCATION", withProperties: ["id": identifier])
                    self.givtManager.stopLookingForGivtLocations()
                    self.giveManually(antennaID: identifier)
                }
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    override func showBluetoothMessage() {
        bluetoothAlert = UIAlertController(
            title: NSLocalizedString("ActivateBluetooth", comment: ""),
            message: NSLocalizedString("BluetoothErrorMessageEvent" , comment: "") + "\n\n" + NSLocalizedString("ExtraBluetoothText", comment: ""),
            preferredStyle: UIAlertControllerStyle.alert)
        bluetoothAlert!.addAction(UIAlertAction(title: NSLocalizedString("GotIt", comment: ""), style: .default, handler: { action in
            
        }))
        present(bluetoothAlert!, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        givtManager.delegate = self
        var shouldAskForLocation = false
        
        if AppServices.isLocationServicesEnabled() && AppServices.isLocationPermissionDetermined() && !AppServices.isLocationPermissionGranted() {
            shouldAskForLocation = true
        }

        shouldShowAfterBluetoothAlert = {
            if shouldAskForLocation {
                self.showLocationMessage()
            }
        }
        
        switch givtManager.getBluetoothState(currentView: self.view) {
        case .enabled:
            if shouldAskForLocation { //only loc disabled
                showLocationMessage()
            }
            givtManager.startLookingForGivtLocations()
        case .disabled:
            if shouldAskForLocation {
                showBluetoothMessage {
                    self.showLocationMessage()
                }
            } else {
                showBluetoothMessage()
            }
        case .unknown:
            print("State will be updated later")
        }
        
        givyContstraint.constant = 20
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.repeat, .autoreverse], animations: {
            self.view.layoutIfNeeded()
        }) { (done) in
        }

        //start timer for showing the "Choose from the list" button
        self.timer20S = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(after20s), userInfo: nil, repeats: false)
    }
    
    override func didUpdateBluetoothState(bluetoothState: BluetoothState) {
        DispatchQueue.main.async {
            if bluetoothState == .enabled {
                self.bluetoothAlert?.dismiss(animated: true, completion: nil)
                self.givtManager.startLookingForGivtLocations()
            } else {
                self.showBluetoothMessage() { self.shouldShowAfterBluetoothAlert() }
            }
        }
    }
    
    func showBluetoothMessage(after: @escaping () -> ()) {
        bluetoothAlert = UIAlertController(
            title: NSLocalizedString("ActivateBluetooth", comment: ""),
            message: NSLocalizedString("BluetoothErrorMessageEvent", comment: "") + "\n\n" + NSLocalizedString("ExtraBluetoothText", comment: ""),
            preferredStyle: UIAlertControllerStyle.alert)
        bluetoothAlert!.addAction(UIAlertAction(title: NSLocalizedString("GotIt", comment: ""), style: .default, handler: { action in
            after()
        }))
        DispatchQueue.main.async {
            self.present(self.bluetoothAlert!, animated: true, completion: nil)
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
    
    @IBAction func giveDifferently(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SelectOrgViewController") as! SelectOrgViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func after20s() {
        UIView.animate(withDuration: 0.3) {
            self.giveDifferently.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.givtManager.stopLookingForGivtLocations()
    }
}
