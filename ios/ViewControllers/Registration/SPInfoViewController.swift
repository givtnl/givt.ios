//
//  SPInfoViewController.swift
//  ios
//
//  Created by Lennie Stockman on 28/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import SVProgressHUD

class SPInfoViewController: UIViewController {
    private var _navigationManager = NavigationManager.shared
    private var _appServices = AppServices.shared
    private var _loginManager = LoginManager.shared
    
    private var log = LogService.shared
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var headerText: UILabel!
    @IBOutlet var explanation: UILabel!
    @IBOutlet var btnNext: CustomButton!
    var hasBackButton = false
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.isEnabled = false
        headerText.text = NSLocalizedString("SlimPayInformation", comment: "")
        explanation.text = NSLocalizedString("SlimPayInformationPart2", comment: "")
        btnNext.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
        // Do any additional setup after loading the view.
        if !hasBackButton {
            self.backButton.isEnabled = false
            self.backButton.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            self.backButton.image = UIImage()
        } else {
            self.backButton.isEnabled = true
        }
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
        let attachment:NSTextAttachment = NSTextAttachment()
        attachment.image = #imageLiteral(resourceName: "littleinfo.png")
        attachment.bounds = CGRect(x: 0, y: -4, width: (attachment.image?.size.width)!, height: (attachment.image?.size.height)!)
        let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
        let myString:NSMutableAttributedString = NSMutableAttributedString(string: NSLocalizedString("SlimPayInformation", comment: "") + " ")
        myString.append(attachmentString)
        
        headerText.attributedText = myString
        let tap = UITapGestureRecognizer(target: self, action: #selector(openSlimPayInfo))
        headerText.addGestureRecognizer(tap)
        headerText.isUserInteractionEnabled = true
        
    }
    
    @objc func openSlimPayInfo() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
        vc.typeOfTerms = .slimPayInfo
        self.present(vc, animated: true, completion: {
            print("done terms")
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func next(_ sender: Any) {
        if !_appServices.connectedToNetwork() {
            _navigationManager.presentAlertNoConnection(context: self)
            return
        }

        NavigationManager.shared.reAuthenticateIfNeeded(context: self) {
            SVProgressHUD.show()
            LoginManager.shared.getUserExtObject { (userExtension) in
                guard let userInfo = userExtension else {
                    SVProgressHUD.dismiss()
                    return
                }
                
                var country = ""
                country = AppConstants.countries[userInfo.CountryCode].shortName
                let signatory = Signatory(givenName: userInfo.FirstName, familyName: userInfo.LastName, iban: userInfo.IBAN, email: userInfo.Email, telephone: userInfo.PhoneNumber, city: userInfo.City, country: country, postalCode: userInfo.PostalCode, street: userInfo.Address)
                let mandate = Mandate(signatory: signatory)
                self._loginManager.requestMandateUrl(mandate: mandate, completionHandler: { slimPayUrl in
                    if slimPayUrl == nil {
                        self.log.warning(message: "Mandate url is empty, what is going on?")
                        SVProgressHUD.dismiss()
                        let alert = UIAlertController(title: NSLocalizedString("NotificationTitle", comment: ""), message: NSLocalizedString("RequestMandateFailed", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Next", comment: ""), style: .cancel, handler: { (action) in
                            self.dismiss(animated: true, completion: {})
                        }))
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: {})
                        }
                    } else {
                        SVProgressHUD.dismiss()
                        self.log.info(message: "Mandate flow will now start")
                        DispatchQueue.main.async {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SPWebViewController") as! SPWebViewController
                            vc.url = slimPayUrl
                            self.show(vc, sender: nil)
                        }
                    }
                })
            }
        }
    }
}
