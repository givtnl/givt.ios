//
//  EmailOnlyViewController.swift
//  ios
//
//  Created by Lennie Stockman on 18/10/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class EmailOnlyViewController: UIViewController {

    @IBOutlet var email: CustomUITextField!
    @IBOutlet var terms: UILabel!
    @IBOutlet var titleItem: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
       navigationController?.setNavigationBarHidden(true, animated: false)

        
        let attachment:NSTextAttachment = NSTextAttachment()
        attachment.image = #imageLiteral(resourceName: "littleinfo.png")
        attachment.bounds = CGRect(x: 0, y: -4, width: (attachment.image?.size.width)!, height: (attachment.image?.size.height)!)
        let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
        let myString:NSMutableAttributedString = NSMutableAttributedString(string: NSLocalizedString("AcceptTerms", comment: "") + " ")
        myString.append(attachmentString)
        
        terms.attributedText = myString
        // Do any additional setup after loading the view.
        
        #if DEBUG
        email.text = String.random() + "@givtapp.com"
        #endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pop(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done(_ sender: Any) {
        //TODO
        //if new account => .giveOnce
        //if account exists => show login
        if true {
            LoginManager.shared.registerEmailOnly(email: email.text!, completionHandler: { (status) in
                if(status) {
                    //user registerend
                    self.navigationController?.dismiss(animated: true, completion: nil)
                } else {
                    
                }
            })
        } else {
            
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

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
