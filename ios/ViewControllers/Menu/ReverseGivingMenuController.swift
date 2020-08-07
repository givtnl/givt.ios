//
//  ReverseGivingMenuController.swift
//  ios
//
//  Created by Mike Pattyn on 07/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import Foundation
import UIKit

class ReverseGivingViewController: BaseMenuViewController {
    private let slideFromRightAnimation = PresentFromRight()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navItem.titleView = UIImageView(image: UIImage(named: "givt20h"))
        
        /* some how we're not able to set the table first cel right below the navigation bar
         * there is a hidden table header somewhere.
         * I haven't found where to change this so, we change the contentinset to -30 */
        table.tableHeaderView = nil
        table.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0)
        table.dataSource = self
        table.delegate = self
    }
    override func loadItems() {
        items = []
        items.append([])
        let firstDestinationThenAmount = Setting(name: "MenuItem_FirstDestinationThenAmount".localized, image: UIImage(named:"hand-holding-heart")!, callback: { self.startFirstDestinationThenAmountFlow() })
        let setupRecurringGift = Setting(name: "Iederne moand ekji", image: UIImage(named:"hand-holding-heart")!, callback: { self.setupRecurringDonation() })
        items[0].append(firstDestinationThenAmount)
        items[0].append(setupRecurringGift)
    }
    private func startFirstDestinationThenAmountFlow() {
        let vc = UIStoryboard(name:"FirstDestinationThenAmount", bundle: nil).instantiateInitialViewController()
        vc?.modalPresentationStyle = .fullScreen
        vc?.transitioningDelegate = self.slideFromRightAnimation
        DispatchQueue.main.async {
            self.hideMenuAnimated() {
                self.present(vc!, animated: true, completion:  nil)
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
    private func setupRecurringDonation() {
        let vc = UIStoryboard(name:"SetupRecurringDonation", bundle: nil).instantiateInitialViewController()
        vc?.modalPresentationStyle = .fullScreen
        vc?.transitioningDelegate = self.slideFromRightAnimation
        DispatchQueue.main.async {
            self.hideMenuAnimated() {
                self.present(vc!, animated: true, completion:  nil)
                self.navigationController?.popViewController(animated: false)
                
            }
        }
    }
}
