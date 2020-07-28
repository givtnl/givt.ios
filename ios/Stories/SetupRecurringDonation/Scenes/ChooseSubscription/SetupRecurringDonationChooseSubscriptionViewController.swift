//
//  ChooseSubscriptionViewController.swift
//  ios
//
//  Created by Mike Pattyn on 27/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import SwiftCron

class SetupRecurringDonationChooseSubscriptionViewController: UIViewController, UIPickerViewDelegate {
    
    private var mediater: MediaterWithContextProtocol = Mediater.shared
    
    private var frequencyPickerView: UIPickerView!
    private var dayPickerView: UIPickerView!
    private var monthPickerView: UIPickerView!

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet var navBar: UINavigationItem!
    @IBOutlet var titleText: UILabel!

    var input: SetupRecurringDonationOpenSubscriptionRoute!
    
    @IBAction func backButton(_ sender: Any) {
        try? mediater.send(request: SetupRecurringDonationBackToChooseDestinationRoute(mediumId: input.mediumId), withContext: self)
    }
    
    @IBAction func makeSubscription(_ sender: Any) {
        if let cronExpression = CronExpression(minute: "0", hour: "0", day: "10", month: "5") {
            let command = CreateSubscriptionCommand(amountPerTurn: 10, nameSpace: input.mediumId, endsAfterTurns: 10, cronExpression: cronExpression.stringRepresentation)
            do {
                try mediater.sendAsync(request: command, completion: { isSuccessful in
                    if isSuccessful {
                        try? self.mediater.send(request: FinalizeGivingRoute())
                    }
                })
            } catch { }
        }
    }
    
}
