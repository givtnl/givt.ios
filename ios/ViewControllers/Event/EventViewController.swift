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
    private let _givtService = GivtService.shared
    private var isSuggestionShowing = false
    @IBOutlet var titleLabel: UILabel!
    private var countdownTimer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(didDiscoverBeacon), name: Notification.Name("DidDiscoverBeacon"), object: nil)
        _givtService.delegate = self
        if _givtService.bluetoothEnabled {
            _givtService.startScanning(shouldNotify: true)
        }
        
        _givtService.startLookingForGivtLocations()
        
        countdownTimer = Timer.scheduledTimer(timeInterval:
            6, target: self, selector: #selector(tickingClocks), userInfo: nil, repeats: true)
        
        
    }
    
    @objc func tickingClocks() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(6)) {
            if let region = self._givtService.getGivtLocation() {
                print(region.name)
                self.titleLabel.text = region.name
                 let alert = UIAlertController(title: region.name, message: "Geef aan zwolleuh", preferredStyle: UIAlertControllerStyle.alert)
                 alert.addAction(UIAlertAction(title: "OKe", style: UIAlertActionStyle.default, handler: { (action) in
                 //todo something
                 }))
                 self.present(alert, animated: true, completion: nil)
 
            }
        }
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
            
            vc.onClose = {
                self._givtService.startScanning(shouldNotify: true)
            }
            vc.onSuccess = {
                self._givtService.give(antennaID: self._givtService.getBestBeacon.beaconId!)
            }
            self.present(vc, animated: true, completion: nil)
            /*
            let alert = UIAlertController(title: "\(orgName)", message: "\(self._givtService.getBestBeacon.beaconId!)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okeeeee 🔪", style: UIAlertActionStyle.default, handler: { (action) in
                self.isSuggestionShowing = false
            }))
            self.present(alert, animated: true, completion: nil)
 */
        }

    }
 
}
