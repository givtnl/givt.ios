//
//  PinViewController.swift
//  ios
//
//  Created by Lennie Stockman on 21/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit

class PinViewController: UIViewController {

    @IBOutlet var switcher: UISwitch!
    @IBOutlet var changePincodeView: UIView!
    @IBOutlet var changePincode: UILabel!
    @IBOutlet var pincode: UILabel!
    @IBOutlet var subtitle: UILabel!
    @IBOutlet var navBar: UINavigationItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
        navBar.title = NSLocalizedString("Pincode", comment: "")
        subtitle.text = NSLocalizedString("PincodeTitleChangingPin", comment: "")
        pincode.text = NSLocalizedString("Pincode", comment: "")
        changePincode.text = NSLocalizedString("PincodeChangePinMenu", comment: "")
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(changePin))
        changePincodeView.isUserInteractionEnabled = true
        changePincodeView.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switcher.isOn = UserDefaults.standard.hasPinSet
        switcher.isUserInteractionEnabled = true
        
        changePincodeView.isUserInteractionEnabled = switcher.isOn
        for childView in changePincodeView.subviews {
            childView.alpha = changePincodeView.isUserInteractionEnabled ? 1.0 : 0.4
        }
    }

    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func changePin() {
        print("wants to change pin")
        let vc = storyboard?.instantiateViewController(withIdentifier: "PinScreenViewController") as! PinScreenViewController
        self.show(vc, sender: self)
    }
    
    
    @IBAction func `switch`(_ sender: Any) {
        let sw = sender as! UISwitch
        if sw.isOn {
            sw.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
                self.changePin()
            })
            
        } else {
            print("pin turned off")
            UserDefaults.standard.hasPinSet = false
            for childView in changePincodeView.subviews {
                changePincodeView.isUserInteractionEnabled = switcher.isOn
                childView.alpha = changePincodeView.isUserInteractionEnabled ? 1.0 : 0.4
            }
        }
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
