//
//  PresetsViewController.swift
//  ios
//
//  Created by Mike Pattyn on 21/02/2019.
//  Copyright © 2019 Givt. All rights reserved.
//

import UIKit

class PresetsSettingsViewController : UIViewController {
    @IBOutlet var backButton: UIBarButtonItem!
  
    @IBOutlet var navBar: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
        navBar.title = NSLocalizedString("AmountPresetsTitle", comment: "")
    }
}
