//
//  LoginNavigationViewController.swift
//  ios
//
//  Created by Lennie Stockman on 25/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class LoginNavigationViewController: UINavigationController {

    var outerHandler : (() -> Void)?
    var emailEditable: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loading")
        //setup nav bar
        
        for i in self.children {
            if outerHandler != nil {
                let vc = i as! LoginViewController
                vc.emailEditable = emailEditable
                vc.completionHandler = { self.outerHandler!() }
            }
            
        }
        removeLogo()
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: "Avenir-Heavy", size: 18)!, NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)]
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }   

}
