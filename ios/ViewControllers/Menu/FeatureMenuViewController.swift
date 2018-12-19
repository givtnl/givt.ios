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

    override func viewWillAppear(_ animated: Bool) {
        navItem.titleView = UIImageView(image: UIImage(named: "givt20h"))
        
        /* some how we're not able to set the table first cel right below the navigation bar
         * there is a hidden table header somewhere.
         * I haven't found where to change this so, we change the contentinset to -30 */
        table.tableHeaderView = nil
        table.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0)
        table.dataSource = self
        table.delegate = self
        super.viewWillAppear(animated)
    }
    
    override func loadItems() {
        items = []
        items.append([])
        for feat in FeatureManager.shared.features {
            let item = Setting(name: feat.value.title, image: UIImage(), showBadge: false, callback: { self.showFeature(which: feat.key) }, showArrow: true, isHighlighted: false)
            items[0].append(item)
        }
    }
    
    private func showFeature(which: Int) {
        if let vc = FeatureManager.shared.getViewControllerForFeature(feature: which) {
            vc.transitioningDelegate = self.slideFromRightAnimation
            vc.btnCloseVisible = false
            vc.btnSkipVisible = false
            self.present(vc, animated: true, completion: {})
        }
    }
}
