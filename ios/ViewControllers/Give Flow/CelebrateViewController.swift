//
//  CelebrateViewController.swift
//  ios
//
//  Created by Lennie Stockman on 18/04/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit
import AudioToolbox

class CelebrateViewController: BaseScanViewController {

    @IBOutlet var gif: UIImageView!
    @IBOutlet var message: UILabel!
    @IBOutlet var timer: UILabel!
    var secondsLeft: Int!
    var countdownTimer: Timer!
    var transactions: [Transaction]!
    private let TORCH_TIME = 10.0
    override func viewDidLoad() {
        super.viewDidLoad()
        #if DEBUG
        secondsLeft = 5
        #endif
        timer.text = formatTime()
        gif.loadGif(name: "celebration")
        title = NSLocalizedString("CelebrateTitle", comment: "")
        message.text = NSLocalizedString("CelebrateMessage", comment: "")
        countdownTimer = Timer.scheduledTimer(timeInterval:
            1, target: self, selector: #selector(tickingClocks), userInfo: nil, repeats: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(secondsLeft) + TORCH_TIME) {
            self.onGivtProcessed(transactions: self.transactions)
        }
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        //no back button
        let backButton = UIBarButtonItem(title: "", style: .plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func formatTime() -> String {
        let minutes = secondsLeft / 60
        let seconds = secondsLeft % 60
        if minutes == 0 {
            return "\(seconds)s"
        } else {
            return "\(minutes)m \(seconds)s"
        }
    }

    @objc func tickingClocks() {
        secondsLeft = secondsLeft - 1
        if secondsLeft <= 0 {
            countdownTimer.invalidate()
            title = NSLocalizedString("AfterCelebrationTitle", comment: "")
            message.text = NSLocalizedString("AfterCelebrationMessage", comment: "")
            timer.text = ""
            InfraManager.shared.flashTorch(length: TORCH_TIME, interval: 0.1)
        } else {
            timer.text = formatTime()
        }
        
    }

}
