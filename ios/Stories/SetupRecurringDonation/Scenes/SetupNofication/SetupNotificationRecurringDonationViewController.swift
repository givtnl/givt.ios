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
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var confirmButton: CustomButton!
    
    var mediater: MediaterWithContextProtocol = Mediater.shared

    @IBOutlet weak var btnAllowPush: CustomButton!

    @IBAction func GoBack(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
    }
    
    @IBAction func Dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
    }
    
    @IBAction func AllowPush(_ sender: CustomButton) {
        NotificationManager.shared.requestNotificationPermission {_ in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: {})
            }
        }
    }
    
    private func setupLabels() {
        descriptionLabel.text = "PushnotificationRequestScreenDescription".localized
        confirmButton.titleLabel!.text = "PushnotificationRequestScreenButtonYes".localized
    }
    
    override func viewDidLoad() {
        setupLabels()
    }
}
