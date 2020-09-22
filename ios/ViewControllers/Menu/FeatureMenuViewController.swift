//
//  FeatureMenuViewController.swift
//  ios
//
//  Created by Maarten Vergouwe on 19/12/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
import UIKit

class FeatureMenuViewController: BaseMenuViewController {
    private let slideFromRightAnimation = PresentFromRight()

    override func viewDidLoad() {
        super.viewDidLoad()
        navItem.titleView = UIImageView(image: UIImage(named: "givt20h"))
        
        /* some how we're not able to set the table first cel right below the navigation bar
         * there is a hidden table header somewhere.
         * I haven't found where to change this so, we change the contentinset to -30 */
        table.tableHeaderView = nil
        table.contentInset = UIEdgeInsets(top: -30, left: 0, bottom: 0, right: 0)
        table.dataSource = self
        table.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(didShowFeature), name: .GivtDidShowFeature, object: nil)
    }
    
    override func loadItems() {
        items = []
        items.append([])
        for feat in FeatureManager.shared.features.sorted(by: {pair1, pair2 in pair1.value.title < pair2.value.title }) {
            let showBadge = feat.value.mustSee && FeatureManager.shared.featuresWithBadge.firstIndex(of: feat.key) != nil
            let item = Setting(name: feat.value.title, image: UIImage(named: feat.value.icon)!, showBadge: showBadge,
                               callback: { self.showFeature(which: feat.key) }, showArrow: true, isHighlighted: false)
            items[0].append(item)
        }
    }
    
    private func showFeature(which: Int) {
        if let vc = FeatureManager.shared.getViewControllerForFeature(feature: which) {
            vc.transitioningDelegate = self.slideFromRightAnimation
            vc.btnCloseVisible = false
            vc.btnSkipVisible = false
            vc.modalPresentationStyle = .fullScreen
            hideMenuAnimated() {
                self.present(vc, animated: true, completion: {})
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
    
    @objc private func didShowFeature(_ notification: NSNotification) {
        if let id = notification.userInfo?["id"] as? Int {
            if let item = items[0].first(where: { s in s.name == FeatureManager.shared.features[id]!.title }) {
                item.showBadge = false
                table.reloadData()
            }
        }
    }
}
