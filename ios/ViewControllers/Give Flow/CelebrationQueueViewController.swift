//
//  CelebrationQueueViewController.swift
//  ios
//
//  Created by Mike Pattyn on 15/04/2019.
//  Copyright © 2019 Givt. All rights reserved.
//

import Foundation
import UIKit
import AppCenterAnalytics
import UserNotifications
import Mixpanel

class CelebrationQueueViewController : BaseScanViewController, NotificationTokenRegisteredDelegate, NotificationReceivedCelebrationDelegate {
    var transactions: [Transaction]!
    var organisation = ""
    var secondsLeft = -1

    @IBOutlet var titelLabel: UILabel!
    @IBOutlet var secondaryTitelLabel: UILabel!
    
    @IBOutlet var imageFlash: UIImageView!

    @IBOutlet var buttonEnablePushNot: CustomButton!
    @IBOutlet var buttonCancelFlashGivt: CustomButton!
    
    override func viewDidLoad() {
        LogService.shared.info(message: "CELEBRATE_QUEUE")
        Analytics.trackEvent("CELEBRATE_QUEUE")
        Mixpanel.mainInstance().track(event: "CELEBRATE_QUEUE")

        UIApplication.shared.isIdleTimerDisabled = true

        // set label texts
        titelLabel.text = NSLocalizedString("CelebrationHappyToSeeYou", comment: "")
        secondaryTitelLabel.text = NSLocalizedString("CelebrationQueueText", comment: "")
        
        // set button texts
        buttonEnablePushNot.setTitle(NSLocalizedString("CelebrationEnablePushNotification", comment: ""), for: UIControl.State.normal)
        buttonEnablePushNot.accessibilityLabel = NSLocalizedString("CelebrationEnablePushNotification", comment: "")
        
        buttonCancelFlashGivt.setTitle(NSLocalizedString("CelebrationQueueCancel", comment: ""), for: UIControl.State.normal)
        buttonCancelFlashGivt.accessibilityLabel = NSLocalizedString("CelebrationQueueCancel", comment: "")
        
        // show/hide and move anchors based on mNotificationManager.notificationsEnabled
        NotificationManager.shared.getNotificationAuthorizationStatus { status in
            DispatchQueue.main.async {
                self.buttonEnablePushNot.isHidden = status == .authorized
                self.imageFlash.bottomAnchor.constraint(equalTo: self.buttonCancelFlashGivt.topAnchor).isActive = status == .authorized
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = true
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = false

        NotificationManager.shared.delegates.append(self)

        NotificationManager.shared.getNotificationAuthorizationStatus { status in
            DispatchQueue.main.async { self.buttonEnablePushNot.isHidden = status == .authorized }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationManager.shared.delegates.removeAll { $0 === self }
        UIApplication.shared.isIdleTimerDisabled = false
        super.viewWillDisappear(animated)
    }
    
    @IBAction func cancelCelebration(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("CelebrationQueueCancelAlertTitle", comment: ""), message: NSLocalizedString("CelebrationQueueCancelAlertBody", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action) in
            LogService.shared.info(message: "CELEBRATE_QUEUE_CANCEL")
            Analytics.trackEvent("CELEBRATE_QUEUE_CANCEL")
            Mixpanel.mainInstance().track(event: "CELEBRATE_QUEUE_CANCEL")
            self.onGivtProcessed(transactions: self.transactions, organisationName: self.organisation, canShare: true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: { (action) in
            self.dismiss(animated: true, completion: {})
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func onNotificationTokenRegistered(token: String?) {
        NotificationManager.shared.getNotificationAuthorizationStatus { status in
            DispatchQueue.main.async { self.buttonEnablePushNot.isHidden = status == .authorized }
        }
    }
    
    func onReceivedCelebration(collectGroupId: String) {
        GivtManager.shared.getSecondsLeftToCelebrate(collectGroupId: collectGroupId, completion: {secondsLeft in
            DispatchQueue.main.async {
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "YayController") as! CelebrateViewController
                vc.transactions = self.transactions
                vc.organisation = self.organisation
                vc.secondsLeft = secondsLeft
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
    @IBAction func activatePushNotfications(_ sender: Any) {
        NotificationManager.shared.requestNotificationPermission(completion: { _ in } )
    }
}
