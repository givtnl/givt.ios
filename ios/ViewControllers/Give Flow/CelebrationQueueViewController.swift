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

class CelebrationQueueViewController : BaseScanViewController, NotificationManagerDelegate {
    
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
        MSAnalytics.trackEvent("CELEBRATE_QUEUE")

        // set label texts
        titelLabel.text = NSLocalizedString("CelebrationHappyToSeeYou", comment: "")
        secondaryTitelLabel.text = NSLocalizedString("CelebrationQueueText", comment: "")
        
        // set button texts
        buttonEnablePushNot.setTitle(NSLocalizedString("CelebrationEnablePushNotification", comment: ""), for: UIControlState.normal)
        buttonEnablePushNot.accessibilityLabel = NSLocalizedString("CelebrationEnablePushNotification", comment: "")
        
        buttonCancelFlashGivt.setTitle(NSLocalizedString("CelebrationQueueCancel", comment: ""), for: UIControlState.normal)
        buttonCancelFlashGivt.accessibilityLabel = NSLocalizedString("CelebrationQueueCancel", comment: "")
        
        // show/hide and move anchors based on mNotificationManager.notificationsEnabled
        let sem = DispatchSemaphore(value: 0)
        NotificationManager.shared.areNotificationsEnabled { enabled in
            DispatchQueue.main.async {
                self.buttonEnablePushNot.isHidden = enabled
                self.imageFlash.bottomAnchor.constraint(equalTo: self.buttonCancelFlashGivt.topAnchor).isActive = enabled
                sem.signal()
            }
        }
        let _ = sem.wait(timeout: .now() + 2.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.titleView = UIImageView(image: UIImage(named: "pg_give_fourth"))
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = true
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = false

        NotificationManager.shared.delegates.append(self)

        let sem = DispatchSemaphore(value: 0)
        NotificationManager.shared.areNotificationsEnabled { enabled in
            DispatchQueue.main.async {
                self.buttonEnablePushNot.isHidden = enabled
                sem.signal()
            }
        }
        let _ = sem.wait(timeout: .now() + 2.0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationManager.shared.delegates.removeAll { $0 === self }
        super.viewWillDisappear(animated)
    }
    
    @IBAction func cancelCelebration(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("CelebrationQueueCancel", comment: ""), message: NSLocalizedString("CelebrationQueueCancelAlertBody", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .cancel, handler: { (action) in
            LogService.shared.info(message: "CELEBRATE_QUEUE_CANCEL")
            MSAnalytics.trackEvent("CELEBRATE_QUEUE_CANCEL")
            self.onGivtProcessed(transactions: self.transactions, organisationName: self.organisation, canShare: true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: {})
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func onNotificationTokenRegistered(token: String?) {
        NotificationManager.shared.areNotificationsEnabled { enabled in
            DispatchQueue.main.async { self.buttonEnablePushNot.isHidden = enabled }
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
        NotificationManager.shared.requestNotificationPermission()
    }
}
