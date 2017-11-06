//
//  ScanCompleteViewController.swift
//  ios
//
//  Created by Lennie Stockman on 24/08/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class ScanCompleteViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        btnBack.setTitle(NSLocalizedString("Ready", comment: ""), for: .normal)
        lblBody.text = NSLocalizedString("GivingSuccess", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        print(GivtService.shared.lastGivtOrg)
        if !GivtService.shared.lastGivtOrg.isEmpty() {
            lblBody.text = NSLocalizedString("GivtIsBeingProcessed", comment: "").replacingOccurrences(of: "{0}", with: GivtService.shared.lastGivtOrg)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBOutlet var btnBack: CustomButton!
    @IBOutlet var lblBody: UILabel!

    @IBAction func btnGoBack(_ sender: Any) {
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
