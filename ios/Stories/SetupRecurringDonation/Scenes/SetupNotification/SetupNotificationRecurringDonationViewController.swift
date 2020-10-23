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
    
    var notificationAuthorizationStatus: NotificationAuthorization? = nil
    
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
        switch notificationAuthorizationStatus {
            case .notDetermined:
                descriptionLabel.text = "Iets anders hier".localized
                confirmButton.setTitle("En hier ook".localized, for: UIControl.State.normal)
                break;
            default:
                descriptionLabel.text = "PushnotificationRequestScreenDescription".localized
                confirmButton.setTitle("PushnotificationRequestScreenButtonYes".localized, for: UIControl.State.normal)
                break;
        }
    }
    
    override func viewDidLoad() {
        setupLabels()
    }
}
