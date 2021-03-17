//
//  RecurringDonationTurnsOverviewControllerPrivateExtension.swift
//  ios
//
//  Created by Mike Pattyn on 17/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

extension RecurringDonationTurnsOverviewController {
    @IBAction override func backPressed(_ sender: Any) {
        try? Mediater.shared.send(request: BackToRecurringDonationOverviewRoute(reloadData: comingFromNotification), withContext: self)
    }
    
    @IBAction func openInfo(_ sender: Any) {
        UIView.animate(withDuration: 1, animations: {
            self.legendOverlay.frame.origin.y = 0
            self.navigationController?.navigationBar.alpha = 0
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func closeInfo() {
        UIView.animate(withDuration: 1, animations: {
            self.legendOverlay.frame.origin.y = -340
            self.navigationController?.navigationBar.alpha = 1
            self.view.layoutIfNeeded()
        })
    }
}
