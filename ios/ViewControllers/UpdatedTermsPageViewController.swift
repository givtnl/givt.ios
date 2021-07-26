//
//  UpdatedTermsPageViewController.swift
//  ios
//
//  Created by Lennie Stockman on 20/12/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit

class UpdatedTermsPageViewController: UIViewController {
    
    @IBOutlet var readBtn: CustomButton!
    @IBOutlet var nextBtn: CustomButton!
    @IBOutlet var secondText: UILabel!
    @IBOutlet var firstText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        firstText.text = NSLocalizedString("TermsUpdate", comment: "")
        secondText.text = NSLocalizedString("AgreeToUpdateTerms", comment: "")
        nextBtn.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
        readBtn.setTitle(NSLocalizedString("IWantToReadIt", comment: ""), for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let id = self.presentedViewController?.restorationIdentifier, id == "TermsViewController" {
            navigationController?.setNavigationBarHidden(true, animated: false)
        } else {
            navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    @IBAction func nextBtn(_ sender: Any) {
        UserDefaults.standard.termsVersion = AppServices.isCountryFromSimGB() ? NSLocalizedString("TermsTextVersionGB", comment: "") : NSLocalizedString("TermsTextVersion", comment: "")
        NavigationManager.shared.load(vc: self.navigationController!, animated: true)
    }
    
    @IBAction func readBtn(_ sender: Any) {
        let vc = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
        vc.typeOfTerms = TypeOfTerms.termsAndConditions
        self.present(vc, animated: true, completion: nil)
    }
}
