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
    @IBOutlet var switcher: UISwitch!
    @IBOutlet var navBar: UINavigationItem!
    @IBOutlet var gotoPresetsView: UIView!
    @IBOutlet var presetsSwitchTitle: UILabel!
    @IBOutlet var presetsGotoTitle: UILabel!
    
    /** ToDo: remember if presets are set  */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
        navBar.title = NSLocalizedString("AmountPresetsTitle", comment: "")
        presetsSwitchTitle.text = NSLocalizedString("AmountPresetsTitle", comment: "")
        presetsGotoTitle.text = NSLocalizedString("AmountPresetsTitle", comment: "")
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(gotoPresets))
        gotoPresetsView.isUserInteractionEnabled = false
        gotoPresetsView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switcher.isOn = UserDefaults.standard.hasPresetsSet

        switcher.isUserInteractionEnabled = true
        
        gotoPresetsView.isUserInteractionEnabled = switcher.isOn
        for childView in gotoPresetsView.subviews {
            childView.alpha = gotoPresetsView.isUserInteractionEnabled ? 1.0 : 0.4
        }
    }
    
    @objc func gotoPresets() {
        let vc = UIStoryboard(name: "AmountPresets", bundle: nil).instantiateViewController(withIdentifier: "AmountPresetsViewController") as! AmountPresetsViewController
        self.show(vc, sender: self)
    }
    @IBAction func `switch`(_ sender: Any) {
        // ToDo: check for better logic where to set this
        UserDefaults.standard.hasPresetsSet = true

        let sw = sender as! UISwitch
        if sw.isOn {
            sw.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
                self.gotoPresets()
            })
        } else {
            UserDefaults.standard.hasPresetsSet = false
            for childView in gotoPresetsView.subviews {
                gotoPresetsView.isUserInteractionEnabled = switcher.isOn
                childView.alpha = gotoPresetsView.isUserInteractionEnabled ? 1.0 : 0.4
            }
        }
        NotificationCenter.default.post(Notification(name: .GivtAmountPresetsSet, object: false, userInfo: nil))
    }
}
