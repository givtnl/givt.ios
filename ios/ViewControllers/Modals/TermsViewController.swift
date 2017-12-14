//
//  TermsViewController.swift
//  ios
//
//  Created by Lennie Stockman on 28/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {

    @IBOutlet var titleText: UILabel!
    @IBOutlet var close: UIButton!
    @IBOutlet var terms: UITextView!
    var typeOfTerms: TypeOfTerms? {
        didSet {
            if typeOfTerms == .privacyPolicy {
                textToShow = NSLocalizedString("PolicyText", comment: "")
                titleToShow = NSLocalizedString("PrivacyTitle", comment: "")
            } else if typeOfTerms == .termsAndConditions {
                textToShow = NSLocalizedString("TermsText", comment: "")
                titleToShow = NSLocalizedString("FullVersionTitleTerms", comment: "")
            }
        }
    }
    
    var titleToShow: String = ""
    var textToShow: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleText.text = self.titleToShow
        self.terms.text = String(self.textToShow.prefix(1000))
        
    }
    
    

    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.terms.text = self.textToShow

        }
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

enum TypeOfTerms {
    case privacyPolicy
    case termsAndConditions
}
