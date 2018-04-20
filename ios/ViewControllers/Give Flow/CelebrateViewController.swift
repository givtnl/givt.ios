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

    @IBOutlet var timer: UILabel!
    var secondsLeft: Int!
    var countdownTimer: Timer!
    var transactions: [Transaction]!
    override func viewDidLoad() {
        super.viewDidLoad()
        #if DEBUG
        secondsLeft = 3
        #endif
        timer.text = String(secondsLeft)
        
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(tickingClocks), userInfo: nil, repeats: true)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    @objc func tickingClocks() {
        secondsLeft = secondsLeft - 1
        if secondsLeft <= 0 {
            
            countdownTimer.invalidate()
            timer.text = "bomb defused 💣"
            let bgTask = UIApplication.shared.beginBackgroundTask {
                //task will end by itself
            }
            InfraManager.shared.flashTorch(length: 10.0, interval: 0.1)
            UIApplication.shared.endBackgroundTask(bgTask)
            
            DispatchQueue.main.async {
                self.onGivtProcessed(transactions: self.transactions)
            }
            
        } else {
            timer.text = String(secondsLeft)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
