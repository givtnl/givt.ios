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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loading")
        //setup nav bar
        
        for i in self.childViewControllers {
            if outerHandler != nil {
                let vc = i as! LoginViewController
                vc.completionHandler = { self.outerHandler!() }
            }
            
        }
        setLogo()
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
