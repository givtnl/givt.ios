//
//  EventViewController.swift
//  ios
//
//  Created by Lennie Stockman on 3/05/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit
import CoreLocation

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
        NotificationCenter.default.addObserver(self, selector: #selector(didDiscoverBeacon), name: Notification.Name("DidDiscoverBeacon"), object: nil)
        _givtService.delegate = self
        if _givtService.bluetoothEnabled {
            _givtService.startScanning(shouldNotify: true)
        }
        
        givyContstraint.constant = 20
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: [.repeat, .autoreverse], animations: {
            self.view.layoutIfNeeded()
        }) { (done) in
        }

        startTimer()
        
        start20sTimer()
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
                GivtService.shared.startLookingForGivtLocations()
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
        vc.organisation = region.organisationName + " - " + region.name
        vc.onClose = {
            self._givtService.startLookingForGivtLocations()
            self.startTimer()
        }
        vc.onSuccess = {
            self._givtService.give(antennaID: region.beaconId)
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("DidDiscoverBeacon"), object: nil)
        GivtService.shared.delegate = nil
        GivtService.shared.stopScanning()
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
                self._givtService.give(antennaID: self._givtService.getBestBeacon.beaconId!)
            }
            self.present(vc, animated: true, completion: nil)
        }

    }
 
}
