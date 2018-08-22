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
    private let _givtService = GivtManager.shared
    private var isSuggestionShowing = false
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var imageV: UIImageView!
    private var countdownTimer: Timer?
    private var timer20S: Timer?
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
    
    override func didDetectGivtLocation(orgName: String, identifier: String) {
        if (self.navigationController?.visibleViewController as? EventSuggestionViewController) != nil {
            return
        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventSuggestionViewController") as! EventSuggestionViewController
        vc.providesPresentationContextTransitionStyle = true
        vc.definesPresentationContext = true
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        vc.organisation = orgName
        vc.onClose = {}
        vc.onSuccess = {
            self.giveManually(antennaID: identifier)
            self._givtService.stopLookingForGivtLocations()
        }
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _givtService.delegate = self
        let bluetoothEnabled = _givtService.isBluetoothEnabled
        var shouldAskForLocation = false
        
        if AppServices.isLocationServicesEnabled() && AppServices.isLocationPermissionDetermined() && !AppServices.isLocationPermissionGranted() {
            shouldAskForLocation = true
        }

        if !bluetoothEnabled && shouldAskForLocation { //if both disabled, show both after each other.
            showBluetoothMessage {
                self.showLocationMessage()
            }
        } else if !bluetoothEnabled { //only BL disabled
            showBluetoothMessage {}
        } else if shouldAskForLocation { //only loc disabled
            showLocationMessage()
        }
        
        _givtService.delegate = self
        _givtService.startLookingForGivtLocations()
        
        givyContstraint.constant = 20
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.repeat, .autoreverse], animations: {
            self.view.layoutIfNeeded()
        }) { (done) in
        }

        //start timer for showing the "Choose from the list" button
        self.timer20S = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(after20s), userInfo: nil, repeats: false)
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
    
    @IBAction func giveDifferently(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ManualGivingViewController") as! ManualGivingViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func after20s() {
        UIView.animate(withDuration: 0.3) {
            self.giveDifferently.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self._givtService.stopLookingForGivtLocations()
    } 
}
