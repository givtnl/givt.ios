//
//  PinNavViewController.swift
//  ios
//
//  Created by Lennie Stockman on 21/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit

class PinNavViewController: UINavigationController {

    
    var outerHandler : ((Bool) -> Void)?
    var typeOfPin: TypeOfPin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: "Avenir-Heavy", size: 18)!, NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)]
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if typeOfPin == .set {
            let vc = storyboard?.instantiateViewController(withIdentifier: "PinViewController") as! PinViewController
            self.setViewControllers([vc], animated: false)
        } else if typeOfPin == .login {
            let vc = storyboard?.instantiateViewController(withIdentifier: "PinScreenViewController") as! PinScreenViewController
            vc.innerHandler = outerHandler
            self.setViewControllers([vc], animated: false)
        }
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

public enum TypeOfPin {
    case set
    case login
}
