//
//  BacsSettingUpViewController.swift
//  ios
//
//  Created by Lennie Stockman on 29/08/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit

class BacsSettingUpViewController: UIViewController {

    @IBOutlet var bodyText: UILabel!
    @IBOutlet var nextButton: CustomButton!
    @IBOutlet var advanceNoticeLabel: UILabel!
    @IBAction func giveConsent(_ sender: Any) {
        let btn = sender as! UIButton
        btn.isSelected = !btn.isSelected
        nextButton.isEnabled = btn.isSelected
    }
    private var helpViewController = UIStoryboard(name: "BACS", bundle: nil).instantiateViewController(withIdentifier: "BacsInfoViewController") as! BacsInfoViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.setBackgroundColor(color: UIColor.init(rgb: 0xE3E2E7), forState: .disabled)
        
        let attachment:NSTextAttachment = NSTextAttachment()
        attachment.image = #imageLiteral(resourceName: "littleinfo.png")
        attachment.bounds = CGRect(x: 0, y: -4, width: (attachment.image?.size.width)!, height: (attachment.image?.size.height)!)
        let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
        let myString:NSMutableAttributedString = NSMutableAttributedString(string: "I have read and understood the advance notice. ") 
        myString.append(attachmentString)
        
        advanceNoticeLabel.attributedText = myString
        let tap = UITapGestureRecognizer(target: self, action: #selector(openAdvanceNotice))
        advanceNoticeLabel.addGestureRecognizer(tap)
        advanceNoticeLabel.isUserInteractionEnabled = true

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    @objc func openAdvanceNotice() {
        helpViewController.title = "Advance notice"
        helpViewController.bodyText = "All the normal Direct Debit safeguards and guarantees apply. No changes in the amount, date, frequency to be debited can be made without notifying you at least five (5) working days in advance of your account being debited. In the event of any error, you are entitled to an immediate refund from your Bank or Building society. You have the right to cancel a Direct Debit Instruction at any time simply by writing to your Bank or Building society, with a copy to use."
        self.present(helpViewController, animated: true, completion: nil)
    }
    @IBAction func openHelp(_ sender: Any) {
        helpViewController.title = "I NEED HELP"
        helpViewController.bodyText = "We all need some help don't we"
        self.present(helpViewController, animated: true, completion: nil)
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
