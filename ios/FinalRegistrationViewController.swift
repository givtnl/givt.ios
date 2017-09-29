//
//  FinalRegistrationViewController.swift
//  ios
//
//  Created by Lennie Stockman on 28/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class FinalRegistrationViewController: UIViewController {

    @IBOutlet var termsLabel: UILabel!
    @IBOutlet var nextButton: CustomButton!
    @IBOutlet var gif: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        gif.loadGif(name: "givt_registration")
        self.view.sendSubview(toBack: gif)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        nextButton.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
        
        initTermsText()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func exit(_ sender: Any) {
        self.hideLeftView(nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    func initTermsText() {
        let attachment:NSTextAttachment = NSTextAttachment()
        attachment.image = #imageLiteral(resourceName: "littleinfo.png")
        attachment.bounds = CGRect(x: 0, y: (termsLabel.font.capHeight - (attachment.image?.size.height)! - 2).rounded(), width: (attachment.image?.size.width)!, height: (attachment.image?.size.height)!)
        let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
        let myString:NSMutableAttributedString = NSMutableAttributedString(string: NSLocalizedString("AcceptTerms", comment: ""))
        myString.append(attachmentString)
        
        termsLabel.attributedText = myString
        let tap = UITapGestureRecognizer(target: self, action: #selector(openTerms))
        termsLabel.addGestureRecognizer(tap)
        termsLabel.isUserInteractionEnabled = true
    }
    
    @objc func openTerms() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
        vc.typeOfTerms = .termsAndConditions
        self.present(vc, animated: true, completion: {
            print("done terms")
        })
    }
    
    @IBAction func finish(_ sender: Any) {
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
