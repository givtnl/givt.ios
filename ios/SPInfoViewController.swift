//
//  SPInfoViewController.swift
//  ios
//
//  Created by Lennie Stockman on 28/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class SPInfoViewController: UIViewController {

    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var headerText: UILabel!
    @IBOutlet var explanation: UILabel!
    @IBOutlet var btnNext: CustomButton!
    @IBOutlet var btnLater: CustomButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.isEnabled = false
        headerText.text = NSLocalizedString("SlimPayInformation", comment: "")
        explanation.text = NSLocalizedString("SlimPayInformationPart2", comment: "")
        btnNext.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
        btnLater.setTitle(NSLocalizedString("AskMeLater", comment: ""), for: .normal)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func next(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SPWebViewController") as! SPWebViewController
        self.show(vc, sender: nil)
    }
    @IBAction func exit(_ sender: Any) {
        
    }
    
    @IBAction func later(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "FinalRegistrationViewController") as! FinalRegistrationViewController
        self.show(vc, sender: nil)
        
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
