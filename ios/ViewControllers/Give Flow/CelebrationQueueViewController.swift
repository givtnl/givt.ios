//
//  CelebrationQueueViewController.swift
//  ios
//
//  Created by Mike Pattyn on 15/04/2019.
//  Copyright © 2019 Givt. All rights reserved.
//

import Foundation
import UIKit

class CelebrationQueueViewController : UIViewController {
    
    var transactions: [Transaction]!
    var organisation = ""
    var secondsLeft = -1
    private var mNotificationManager: NotificationManager = NotificationManager()

    @IBOutlet var titelLabel: UILabel!
    @IBOutlet var secondaryTitelLabel: UILabel!
    
    @IBOutlet var imageFlash: UIImageView!

    @IBOutlet var buttonEnablePushNot: CustomButton!
    @IBOutlet var buttonCancelPartyGivt: CustomButton!
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(shouldShowCelebration), name: .GivtReceivedCelebrationNotification, object: nil)

        // set label texts
        titelLabel.text = NSLocalizedString("CelebrationHappyToSeeYou", comment: "")
        secondaryTitelLabel.text = NSLocalizedString("CelebrationQueueText", comment: "")
        
        // set button texts
        buttonEnablePushNot.setTitle(NSLocalizedString("CelebrationEnablePushNotification", comment: ""), for: UIControlState.normal)
        let cancelString = NSLocalizedString("CelebrationQueueCancel", comment: "")
        let cancelStringMutable = NSMutableAttributedString(string: cancelString)
        cancelStringMutable.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0, length: cancelString.count))
        buttonCancelPartyGivt.setAttributedTitle(cancelStringMutable, for: UIControlState.normal)
        
        // show/hide and move anchors based on mNotificationManager.notificationsEnabled
        buttonEnablePushNot.isHidden = mNotificationManager.notificationsEnabled
        imageFlash.bottomAnchor.constraint(equalTo: buttonCancelPartyGivt.topAnchor).isActive = mNotificationManager.notificationsEnabled
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.titleView = UIImageView(image: UIImage(named: "pg_give_fourth"))
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = true
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = false
    }
    @objc func shouldShowCelebration(notification: NSNotification){
        
        if let data = notification.userInfo as? [String : String] {
            if let collectGroupId = data["CollectGroupId"] {
                GivtManager.shared.getSecondsLeftToCelebrate(collectGroupId: collectGroupId, completion: {secondsLeft in //TODO: Change colelctgroupid
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
        }
    }
}
