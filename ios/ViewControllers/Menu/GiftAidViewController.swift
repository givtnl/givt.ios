//
//  GiftAidViewController.swift
//  ios
//
//  Created by Bjorn Derudder on 07/06/2019.
//  Copyright © 2019 Givt. All rights reserved.
//

import Foundation
import UIKit

class GiftAidViewController: UIViewController {
    
    var uExt: LMUserExt?
    
    @IBOutlet weak var giftAidSwitch: UISwitch!
    @IBAction func readyAction(_ sender: Any) {
        LoginManager.shared.updateUser(uext: self.uExt!, completionHandler: { (ok) in
            if ok {
                DispatchQueue.main.async {
                    self.backPressed(self)
                }
            } else {
                let alertController = UIAlertController(title: "Oops", message:
                    "Something went wrong" , preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default))
                
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
    @IBAction func giftAidChanged(_ sender: Any) {
        
        let giftaidOn = giftAidSwitch.isOn
        if (giftaidOn) {
            uExt?.GiftAid = Date()
        } else {
            uExt?.GiftAid = nil
        }
    }
    
    override func viewDidLoad() {
        giftAidSwitch.setOn(uExt?.GiftAid != nil, animated: false)
    }
    
}
