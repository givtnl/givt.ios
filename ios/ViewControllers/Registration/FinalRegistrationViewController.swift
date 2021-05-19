//
//  FinalRegistrationViewController.swift
//  ios
//
//  Created by Lennie Stockman on 28/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import AppCenterAnalytics
import Mixpanel

class FinalRegistrationViewController: UIViewController {

    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var termsLabel: UILabel!
    @IBOutlet var nextButton: CustomButton!
    @IBOutlet var gif: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        MSAnalytics.trackEvent("User finished registration")
        Mixpanel.mainInstance().track(event: "User finished registration")

        gif.loadGif(name: "givt_registration")
        self.view.sendSubviewToBack(gif)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        nextButton.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
        titleLabel.text = NSLocalizedString("RegistrationSuccess", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func exit(_ sender: Any) {
        APIClient.shared.head(url: "/api/v2/users/\(UserDefaults.standard.userExt!.guid)") { response in
            DispatchQueue.main.async {
                self.hideLeftView(nil)
                self.dismiss(animated: true, completion: nil)
                if let resp = response {
                    if let header = resp.headers.first(where: { (key, value) in
                        key == "x-givt-donations-count"
                    }) {
                        if let count = Int(header.value) {
                            if count > 0 {
                                NavigationManager.shared.loadHistoryPage(animated: true)
                            } else {
                                NavigationManager.shared.loadMainPage(animated: false)
                            }
                        } else {
                            NavigationManager.shared.loadMainPage(animated: false)
                        }
                    } else {
                        NavigationManager.shared.loadMainPage(animated: false)
                    }
                } else {
                    NavigationManager.shared.loadMainPage(animated: false)
                }
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
