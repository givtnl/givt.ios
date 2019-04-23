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
    
    var secondsLeft: Int!
    var transactions: [Transaction]!
    var organisation = ""
    
    private var mNotificationManager: NotificationManager = NotificationManager()

    @IBOutlet var titelLabel: UILabel!
    @IBOutlet var secondaryTitelLabel: UILabel!
    
    @IBOutlet var imageFlash: UIImageView!

    @IBOutlet var buttonEnablePushNot: CustomButton!
    @IBOutlet var buttonCancelPartyGivt: CustomButton!
    
    override func viewDidLoad() {
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
}
