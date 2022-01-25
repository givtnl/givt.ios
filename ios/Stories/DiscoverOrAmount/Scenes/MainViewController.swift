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
    private let modalAnimation = CustomPresentModalAnimation()
    
    var showHistory = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = .clear
        outerView.layer.borderWidth = 1
        outerView.layer.borderColor = ColorHelper.LightGrey.cgColor
        outerView.layer.cornerRadius = 8;
        outerView.layer.masksToBounds = true;
        menu.image = BadgeService.shared.hasBadge() ? #imageLiteral(resourceName: "menu_badge") : #imageLiteral(resourceName: "menu_base")
        menu.accessibilityLabel = "Menu"
        faqButton.accessibilityLabel = NSLocalizedString("FAQButtonAccessibilityLabel", comment: "")
        titleNav.title = "Amount".localized
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont(name: "Avenir-Heavy", size: 14)!], for: .normal)
        segmentControl.setTitle("DiscoverSegmentNow".localized, forSegmentAt: 0)
        segmentControl.setTitle("DiscoverSegmentWho".localized, forSegmentAt: 1)
        
        if #available(iOS 13.0, *) {
            segmentControl.selectedSegmentTintColor = ColorHelper.GivtLightGreen
        } else {
            segmentControl.tintColor = ColorHelper.GivtLightGreen
        }
        if self.presentedViewController?.restorationIdentifier == "FAQViewController" {
            self._cameFromFAQ = true
        }
        
        if showHistory {
            let history = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HistoryFlow") as! BaseNavigationController
            self.present(history, animated: false)
        }
        }
    override func viewDidAppear(_ animated: Bool) {
        navigationManager.delegate = self

        if self.sideMenuController!.isLeftViewHidden && !self._cameFromFAQ {
            navigationManager.finishRegistrationAlert(self)
        }
        self._cameFromFAQ = false

    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(checkBadges), name: .GivtBadgeNumberDidChange, object: nil)
    }
    
    @IBAction func segmentControlValueChanged(_ sender: Any) {
        NotificationCenter.default.post(name: .GivtSegmentControlStateDidChange, object: nil)
    }
}

extension MainViewController: NavigationManagerDelegate, UIPageViewControllerDelegate {
    @objc func checkBadges(notification:Notification) {
        DispatchQueue.main.async {
            self.menu.image = BadgeService.shared.hasBadge() ? #imageLiteral(resourceName: "menu_badge") : #imageLiteral(resourceName: "menu_base")
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "faq" {
            let destination = segue.destination
            destination.transitioningDelegate = modalAnimation
        }
    }
    func willResume(sender: NavigationManager) {
        if ((self.presentedViewController as? UIAlertController) == nil) {
            if (self.sideMenuController?.isLeftViewHidden)! && !self._cameFromFAQ {
                navigationManager.finishRegistrationAlert(self)
            }
            self._cameFromFAQ = false
        }
    }
    
    @IBAction func toggleLeftViewAnimated(sender: Any?) {
        self.sideMenuController?.toggleLeftViewAnimated(sender: sender)
    }
}
