//
//  AboutNavigationController.swift
//  ios
//
//  Created by Lennie Stockman on 15/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLogo()
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(rgb: 0x2E2957), NSAttributedString.Key.font: UIFont(name: "Avenir-Heavy", size: 18)!]
        // Do any additional setup after loading the view.
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
