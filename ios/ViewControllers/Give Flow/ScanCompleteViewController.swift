//
//  ScanCompleteViewController.swift
//  ios
//
//  Created by Lennie Stockman on 24/08/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class ScanCompleteViewController: UIViewController {
    var organisation = ""
    var bestBeacon = BestBeacon()
    override func viewDidLoad() {
        super.viewDidLoad()
        btnBack.setTitle(NSLocalizedString("Ready", comment: ""), for: .normal)
        shareWithFriends.setTitle(NSLocalizedString("ShareTheGivtButton", comment: ""), for: .normal)
        lblBody.text = NSLocalizedString("OfflineGegevenGivtMessage", comment: "")
        lblTitle.text = NSLocalizedString("YesSuccess", comment: "")
        if let beaconId = bestBeacon.beaconId, beaconId.substring(16..<19).matches("c[0-9]|d[be]") {
            shareWithFriends.removeFromSuperview()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if !organisation.isEmpty() {
            lblBody.text = NSLocalizedString("OfflineGegevenGivtMessageWithOrg", comment: "").replacingOccurrences(of: "{0}", with: organisation)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    @IBOutlet var btnBack: CustomButton!
    @IBOutlet var lblBody: UILabel!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var shareWithFriends: CustomButton!
    
    @IBAction func shareGivtWithFriends(_ sender: Any) {
        print("sharing givt")

        var message = organisation.isEmpty() ? NSLocalizedString("ShareTheGivtTextNoOrg", comment: "") : NSLocalizedString("ShareTheGivtText", comment: "").replacingOccurrences(of: "{0}", with: organisation)
        message += " " + NSLocalizedString("JoinGivt", comment: "")
        
        let activityViewController = UIActivityViewController(activityItems: [message as NSString], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: {})
        
    }
    @IBAction func nextBtn(_ sender: Any) {
        if let amountVC = self.navigationController?.childViewControllers[0] as? AmountViewController {
            amountVC.reset()
        }
        self.navigationController?.popToRootViewController(animated: true)
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
