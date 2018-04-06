//
//  CustomViewController.swift
//  ios
//
//  Created by Lennie Stockman on 12/07/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import LGSideMenuController

class CustomViewController: UINavigationController  {
    let slideAnimator = CustomPresentModalAnimation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        NavigationManager.shared.load(vc: self, animated: false)
    }
    @IBAction func unwindToAmount(segue: UIStoryboardSegue) {
        
    }
    
    func changeContext() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChooseContextViewController") as! ChooseContextViewController
        let nc = storyboard?.instantiateViewController(withIdentifier: "ContextNavigationController") as! BaseNavigationController
        nc.setViewControllers([vc], animated: true)
        
        //pass callback when done setting context
        nc.transitioningDelegate = self.slideAnimator
        vc.completion = { context in
            DispatchQueue.main.async {
                self.setViewControllers([self.childViewControllers[0]], animated: false) //clear stack
                NavigationManager.shared.showContextSituation(self, tempContext: context)
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        DispatchQueue.main.async {
            self.present(nc, animated: true) {
                
            }
        }
    }
    
}
