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
    @IBOutlet weak var giftAidSwitch: UISwitch!
    @IBAction func readyAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.backPressed(self)
        }
    }
    @IBAction func giftAidChanged(_ sender: Any) {
        let alertController = UIAlertController(title: "GiftAid changed", message:
            "GiftAid changed to : " + giftAidSwitch.isOn.description , preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
