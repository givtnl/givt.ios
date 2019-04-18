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
    
    @IBOutlet var titelLabel: UILabel!
    @IBOutlet var secondaryTitelLabel: UILabel!
    
    @IBOutlet var buttonEnablePushNot: CustomButton!
    @IBOutlet var buttonCancelPartyGivt: CustomButton!
    
    override func viewDidLoad() {
        navigationItem.title = "Queue titel"
        titelLabel.text = NSLocalizedString("CelebrationHappyToSeeYou", comment: "")
        secondaryTitelLabel.text = NSLocalizedString("CelebrationQueueText", comment: "")
        buttonEnablePushNot.setTitle(NSLocalizedString("CelebrationEnablePushNotification", comment: ""), for: UIControlState.normal)
        let cancelString = NSLocalizedString("CelebrationQueueCancel", comment: "")
        let cancelStringMutable = NSMutableAttributedString(string: cancelString)
        cancelStringMutable.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0, length: cancelString.count))
        buttonCancelPartyGivt.setAttributedTitle(cancelStringMutable, for: UIControlState.normal)
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
