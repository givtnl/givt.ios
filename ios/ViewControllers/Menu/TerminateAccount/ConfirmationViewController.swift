//
//  ConfirmationViewController.swift
//  ios
//
//  Created by Lennie Stockman on 15/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit

class ConfirmationViewController: UIViewController {

    @IBOutlet var backBtn: UIBarButtonItem!
    @IBOutlet var subTitle: UILabel!
    @IBOutlet var headerTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        headerTitle.text = NSLocalizedString("UnregisterSad", comment: "")
        backBtn.isEnabled = false
        backBtn.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            // Put your code which should be executed with a delay here
            self.hideLeftView(nil)
            self.performSegue(withIdentifier: "unwindAmount", sender: self)
            NavigationManager.shared.loadMainPage(animated: false)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
