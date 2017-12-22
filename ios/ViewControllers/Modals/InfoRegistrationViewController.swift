//
//  InfoRegistrationViewController.swift
//  ios
//
//  Created by Lennie Stockman on 18/12/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit

class InfoRegistrationViewController: UIViewController {

    @IBOutlet var buttonText: CustomButton!
    @IBOutlet var bodyText: UILabel!
    @IBOutlet var titleText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        titleText.text = NSLocalizedString("PersonalInfo", comment: "")
        bodyText.text = NSLocalizedString("InformationPersonalData", comment: "")
        buttonText.setTitle(NSLocalizedString("ReadPrivacy", comment: ""), for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var close: UIButton!
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func openStatement(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
        vc.typeOfTerms = TypeOfTerms.privacyPolicy
        self.present(vc, animated: true, completion: nil)
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
