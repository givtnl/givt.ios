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
    public var featureId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didShowFeature), name: .GivtDidShowFeature, object: nil)
    }
    
    override func loadItems() {
        items = []
        items.append([])
        for feat in FeatureManager.shared.features.sorted(by: {pair1, pair2 in pair1.value.id < pair2.value.id }) {
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
