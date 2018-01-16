//
//  TaxesViewController.swift
//  ios
//
//  Created by Lennie Stockman on 15/01/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit

class TaxesViewController: UIViewController {

    @IBOutlet var sendBtn: CustomButton!
    @IBOutlet var secondText: UILabel!
    @IBOutlet var firstText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mutableAttributedString = NSMutableAttributedString()
        
        let boldAttribute = [
            NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17)!,
            NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
            ] as [NSAttributedStringKey : Any]
        
        let boldAttributedString = NSAttributedString(string: UserDefaults.standard.userExt!.email, attributes: boldAttribute)
        mutableAttributedString.append(NSAttributedString(string: NSLocalizedString("SendOverViewTo", comment: "")))
        mutableAttributedString.append(boldAttributedString)

        firstText.text = NSLocalizedString("DownloadYearOverview", comment: "")
        secondText.attributedText = mutableAttributedString
        
        
        sendBtn.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var goBack: UIBarButtonItem!
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func send(_ sender: Any) {
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
