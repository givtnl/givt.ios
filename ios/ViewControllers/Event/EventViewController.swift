//
//  EventViewController.swift
//  ios
//
//  Created by Lennie Stockman on 3/05/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit

class EventViewController: BaseScanViewController {
    private let _givtService = GivtService.shared
    private var isSuggestionShowing = false
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("DidDiscoverBeacon"), object: nil)
        GivtService.shared.delegate = nil
        GivtService.shared.stopScanning()
    }
    
    @objc func didDiscoverBeacon(notification: NSNotification) {
        GivtService.shared.stopScanning()

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
