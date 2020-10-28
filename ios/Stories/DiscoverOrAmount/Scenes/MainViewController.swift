//
//  MainViewController.swift
//  ios
//
//  Created by Mike Pattyn on 27/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var menu: UIBarButtonItem!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var titleNav: UINavigationItem!
    @IBOutlet weak var faqButton: UIBarButtonItem!
    
    private let items = ["Geef nu", "Ontdek wie"]
    private var navigationManager: NavigationManager = NavigationManager.shared
    private var _cameFromFAQ: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = .clear
        outerView.layer.borderWidth = 1
        outerView.layer.borderColor = UIColor.gray.cgColor
        outerView.layer.cornerRadius = 8;
        outerView.layer.masksToBounds = true;
        menu.image = BadgeService.shared.hasBadge() ? #imageLiteral(resourceName: "menu_badge") : #imageLiteral(resourceName: "menu_base")
        menu.accessibilityLabel = "Menu"
        
        if self.presentedViewController?.restorationIdentifier == "FAQViewController" {
            self._cameFromFAQ = true
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if self.sideMenuController!.isLeftViewHidden && !self._cameFromFAQ {
            navigationManager.finishRegistrationAlert(self)
        }
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(checkBadges), name: .GivtBadgeNumberDidChange, object: nil)
    }
    
    @IBAction func segmentControlValueChanged(_ sender: Any) {
        NotificationCenter.default.post(name: .GivtSegmentControlStateDidChange, object: nil)
    }
    
}

extension MainViewController {
    @objc func checkBadges(notification:Notification) {
        DispatchQueue.main.async {
            self.menu.image = BadgeService.shared.hasBadge() ? #imageLiteral(resourceName: "menu_badge") : #imageLiteral(resourceName: "menu_base")
        }
    }
}
