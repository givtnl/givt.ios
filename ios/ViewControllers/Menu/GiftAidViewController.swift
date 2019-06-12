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
        DispatchQueue.main.async {
            self.backPressed(self)
        }
    }
    @IBAction func giftAidChanged(_ sender: Any) {
        
        let giftaidOn = giftAidSwitch.isOn
        if (giftaidOn) {
            uExt?.GiftAid = Date()
        } else {
            uExt?.GiftAid = nil
        }
        
        LoginManager.shared.updateUserExt(userExt: uExt!) { (ok) in
            if ok {
                let alertController = UIAlertController(title: "GiftAid changed", message:
                    "GiftAid changed to : " + self.giftAidSwitch.isOn.description , preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default))
                
                self.present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Oops", message:
                   "Something went wrong" , preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        giftAidSwitch.isOn = uExt?.GiftAid != nil
    }
    
}
