//
//  SepaMandateVerificationViewController.swift
//  ios
//
//  Created by Bjorn Derudder on 04/01/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import CoreGraphics

class SepaMandateVerificationViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonalSettingTableViewCell", for: indexPath) as! PersonalSettingTableViewCell
        cell.labelView.text = settings[indexPath.row].name
        cell.img.image = settings[indexPath.row].image
        cell.selectionStyle = .none
        cell.accessoryType = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    
    private var _country: String = ""
    private var _navigationManager = NavigationManager.shared
    private var _appServices = AppServices.shared
    private var _loginManager = LoginManager.shared
    private var log = LogService.shared
        
    @IBOutlet weak var btnNext: CustomButton!
    @IBOutlet weak var tblPersonalData: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMandateDisclaimer: UILabel!
    @IBOutlet weak var lblVerifyData: UILabel!
    
    private var settings: [PersonalSetting] = []
    
    private var uExt: LMUserExt?
    
    struct PersonalSetting {
        var image: UIImage
        var name: String
        var type: SettingType
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = UIImageView(image: UIImage(imageLiteralResourceName: "givt20h.png"))

        tblPersonalData.delegate = self
        tblPersonalData.dataSource = self
        tblPersonalData.allowsSelection = false
        tblPersonalData.separatorStyle = .none
        
        btnNext.setTitle(NSLocalizedString("SignMandate", comment: ""), for: .normal)
        lblTitle.text = NSLocalizedString("BacsVerifyTitle", comment: "");
        lblMandateDisclaimer.text = NSLocalizedString("SignMandateDisclaimer", comment: "");
        lblVerifyData.text = NSLocalizedString("SepaVerifyBody", comment: "");
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /* We may have lost internet connection when coming back from a personal info change setting viewcontroller */
        if AppServices.shared.isServerReachable {
            SVProgressHUD.show()
            _loginManager.getUserExt { (userExtObject) in
                SVProgressHUD.dismiss()
                self.uExt = userExtObject
                guard let userExt = userExtObject else {
                    let alert = UIAlertController(title: NSLocalizedString("RequestFailed", comment: ""), message: NSLocalizedString("CantFetchPersonalInformation", comment: ""), preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                        DispatchQueue.main.async {
                            self.backPressed(self)
                        }
                    }))
                    return
                }
                self._country = AppConstants.countries.filter { (c) -> Bool in
                    c.shortName == userExt.Country
                    }[0].name
                
                self.settings.removeAll()
                self.settings.append(PersonalSetting(image: #imageLiteral(resourceName: "personal_gray"), name: userExt.FirstName! + " " + userExt.LastName!, type: .name))
                self.settings.append(PersonalSetting(image: #imageLiteral(resourceName: "email_sign"), name: userExt.Email, type: .emailaddress))
                self.settings.append(PersonalSetting(image: #imageLiteral(resourceName: "house"), name: userExt.Address! + "\n" + userExt.PostalCode! + " " + userExt.City! + ", " + self._country, type: .address))
                if let iban = userExt.IBAN {
                    self.settings.append(PersonalSetting(image: #imageLiteral(resourceName: "card"), name: iban.separate(every: 4, with: " "), type: .iban))
                } else if let sortCode = userExt.SortCode, let accountNumber = userExt.AccountNumber {
                    self.settings.append(PersonalSetting(image: #imageLiteral(resourceName: "card"), name: NSLocalizedString("BacsSortcodeAccountnumber", comment: "").replacingOccurrences(of: "{0}", with: sortCode).replacingOccurrences(of: "{1}", with: accountNumber), type: .bacs))
                }
                
                DispatchQueue.main.async {
                    self.tblPersonalData.reloadData()
                    // Auto adjust the table height to the height of the content
                    self.tblPersonalData.layoutIfNeeded()
                    var frame = self.tblPersonalData.frame;
                    frame.size.height = self.tblPersonalData.contentSize.height;
                    self.tblPersonalData.frame = frame;
                    self.tblPersonalData.layoutIfNeeded()
                }
            }
        }
    }
    
    @IBAction func SignMandate(_ sender: Any) {
        (sender as! UIButton).isEnabled = false

        if !_appServices.isServerReachable {
            _navigationManager.presentAlertNoConnection(context: self)
            return
        }
        
        NavigationManager.shared.reAuthenticateIfNeeded(context: self) {
            SVProgressHUD.show()
            self._loginManager.registerMandate(completionHandler: { (response) in
                SVProgressHUD.dismiss()
                var hasError = true
                if let r = response {
                    
                    if (r.basicStatus == .ok) {
                        hasError = false
                        self._loginManager.checkMandate(completionHandler: { status in
                            DispatchQueue.main.async {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "FinalRegistrationViewController") as! FinalRegistrationViewController
                                self.show(vc, sender: nil)
                            }
                        })
                    }
                    
                    if hasError {
                        let alert = UIAlertController(
                            title: "RequestFailed".localized,
                            message: "RequestMandateFailed".localized,
                            preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            NavigationManager.shared.loadMainPage()
                            self.dismiss(animated: true, completion: {})
                        }))
                        if (r.statusCode == 400) {
                            alert.title = "RequestFailed".localized
                            alert.message = "MandateFailPersonalInformation".localized
                        } else if (r.statusCode == 409) {
                            alert.title = "RequestFailed".localized
                            alert.message = "DuplicateAccountOrganisationMessage".localized
                        }
                        
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: {})
                        }
                    }
                }})
        }
    }
}
