//
//  SetupNotificationRecurringDonationViewController.swift
//  ios
//
//  Created by Jonas Brabant on 16/09/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class SetupNotificationRecurringDonationViewController: UIViewController
{
    var mediater: MediaterWithContextProtocol = Mediater.shared

    @IBOutlet weak var btnAllowPush: CustomButton!
    
    
    
    
    @IBAction func AllowPush(_ sender: CustomButton) {
        NotificationManager.shared.requestNotificationPermission {_ in
            DispatchQueue.main.async {
                try? self.mediater.send(request: BackToRecurringDonationOverviewRoute(), withContext: self)
            }
        }
    }
}
