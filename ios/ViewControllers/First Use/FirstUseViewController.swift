//
//  FirstUseViewController.swift
//  ios
//
//  Created by Lennie Stockman on 18/10/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class FirstUseViewController: UIViewController {

    let subtiel : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 17)!,
        NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.3513332009, green: 0.3270585537, blue: 0.5397221446, alpha: 1),
        NSAttributedString.Key.underlineStyle : 0]
    
    let focus : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 18)!,
        NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1),
        NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var getStarted: CustomButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sideMenuController?.hideLeftViewAnimated(sender: self)
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = false
        getStarted.setTitle(NSLocalizedString("WelcomeContinue", comment: ""), for: .normal)
        // Do any additional setup after loading the view.
        
        let attributedString = NSMutableAttributedString(string: NSLocalizedString("AlreadyAnAccount", comment: "") + " ", attributes: subtiel)
        attributedString.append(NSMutableAttributedString(string: NSLocalizedString("Login", comment: ""), attributes: focus))
        
        loginButton.setAttributedTitle(attributedString, for: UIControl.State.normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(_ sender: Any) {
        DispatchQueue.main.async {
            NavigationManager.shared.executeWithLogin(context: self, emailEditable: true) {
                self.navigationController?.dismiss(animated: false, completion: nil)
                NavigationManager.shared.loadMainPage()
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
