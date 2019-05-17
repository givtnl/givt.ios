//
//  TerminateAccountViewController.swift
//  ios
//
//  Created by Lennie Stockman on 15/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit
import SVProgressHUD

class TerminateAccountViewController: UIViewController {

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet var confirmationLabel: UILabel!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var check: UIButton!
    @IBAction func check(_ sender: Any) {
        check.isSelected = !check.isSelected
        terminate.isEnabled = check.isSelected
    }
    @IBOutlet var terminate: CustomButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
        terminate.setBackgroundColor(color: #colorLiteral(red: 0.8901960784, green: 0.8862745098, blue: 0.9058823529, alpha: 1), forState: .disabled)
        check.setImage(#imageLiteral(resourceName: "checked"), for: .selected)
        terminate.isEnabled = false

        textLabel.text = NSLocalizedString("UnregisterInfo", comment: "")
        confirmationLabel.text = NSLocalizedString("UnregisterUnderstood", comment: "")
        terminate.setTitle(NSLocalizedString("UnregisterButton", comment: ""), for: .normal)
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
        
        self.navigationController?.removeLogo()
        title = NSLocalizedString("Unregister", comment: "")
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 18)!, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func terminate(_ sender: Any) {
        SVProgressHUD.show()
        if !AppServices.shared.isServerReachable {
            SVProgressHUD.dismiss()
            let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("ConnectionError", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            }))
            self.present(alert, animated: true, completion:  {})
            return
        }
        LoginManager.shared.terminateAccount { (status) in
            SVProgressHUD.dismiss()
            if !status {
                let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("ConnectionError", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                }))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion:  {})
                }
            } else {
                DispatchQueue.main.async {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationViewController") as! ConfirmationViewController
                    self.show(vc, sender: nil)
                }
            }
        }
    }
}
