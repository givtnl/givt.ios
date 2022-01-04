//
//  AmountViewController.swift
//  ios
//
//  Created by Lennie Stockman on 12/07/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import LGSideMenuController

class FirstViewController: LGSideMenuController, LGSideMenuDelegate {
    func didTransformRootView(sideMenuController: LGSideMenuController, percentage: CGFloat) {}
    func didTransformLeftView(sideMenuController: LGSideMenuController, percentage: CGFloat) {}
    func didTransformRightView(sideMenuController: LGSideMenuController, percentage: CGFloat) {}
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func willShowLeftView(_ leftView: UIView, sideMenuController: LGSideMenuController) {
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func willHideLeftView(_ leftView: UIView, sideMenuController: LGSideMenuController) {
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewDidLoad() {
        super.delegate = self
        setNeedsStatusBarAppearanceUpdate()
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        leftViewPresentationStyle = .slideAside
    }
    

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
