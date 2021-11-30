//
//  DiscoverOrAmountSetupSingleDonationViewController.swift
//  ios
//
//  Created by Mike Pattyn on 29/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import MaterialShowcase
import AppCenterCrashes
import AppCenterAnalytics
import SVProgressHUD
import Mixpanel
import SafariServices

class DiscoverOrAmountSetupSingleDonationViewController: UIViewController, UIGestureRecognizerDelegate, SFSafariViewControllerDelegate {
    private var mediater: MediaterWithContextProtocol = Mediater.shared

    var input: DiscoverOrAmountOpenSetupSingleDonationRoute!
    
    @IBOutlet var giveButton: CustomButtonWithRightArrow!
    @IBOutlet var removeButton: CustomButton!
    @IBOutlet var commaButton: UIButton!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet weak var amountControl: CollectionView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var presetView: UIView!
    @IBOutlet weak var presetButton1: PresetButton!
    @IBOutlet weak var presetButton2: PresetButton!
    @IBOutlet weak var presetButton3: PresetButton!
    
    var amountLimit = 0
    
    private var decimalNotation: String! = "," {
        didSet {
            commaButton.setTitle(decimalNotation, for: .normal)
            let fmt = NumberFormatter()
            fmt.minimumFractionDigits = 2
            fmt.minimumIntegerDigits = 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        amountLimit = UserDefaults.standard.amountLimit
        
        amountControl.collectLabel.isHidden = true
        amountControl.deleteBtn.isHidden = true
        amountControl.currency = UserDefaults.standard.currencySymbol
        amountControl.isActive = true
        
        giveButton.labelText.text = "Give".localized
        giveButton.labelText.adjustsFontSizeToFitWidth = true
        giveButton.accessibilityLabel = "Give".localized
        giveButton.setBackgroundColor(color: UIColor.init(rgb: 0xE3E2E7), forState: .disabled)
        
        navigationTitle.title = "Amount".localized
        
        removeButton.accessibilityLabel = "RemoveBtnAccessabilityLabel".localized
        
        backButton.accessibilityLabel = "Back".localized
        
        checkAmount()
        checkPresetButtons()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        decimalNotation = NSLocale.current.decimalSeparator! as String
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func backButton(_ sender: Any) {
        try? mediater.send(request: DiscoverOrAmountBackToSelectDestinationRoute(amount: amountControl.amount), withContext: self)
    }
    
    @IBAction func giveButtonTouchDown(_ sender: Any) {
        giveButton.ogBGColor = #colorLiteral(red: 0.1098039216, green: 0.662745098, blue: 0.4235294118, alpha: 1)
    }
    
    @IBAction func giveButtonTouchDragOutside(_ sender: Any) {
        giveButton.ogBGColor = #colorLiteral(red: 0.2529559135, green: 0.789002955, blue: 0.554667592, alpha: 1)
    }

    @IBAction func giveButton(_ sender: Any) {
        giveButton.ogBGColor = #colorLiteral(red: 0.2529559135, green: 0.789002955, blue: 0.554667592, alpha: 1)
        do {
            let user = try mediater.send(request: GetLocalUserConfiguration())
            guard let userId = user.userId else {
                LogService.shared.error(message: "Trying to donate without valid userId")
                hideLoader()
                return
            }
            let amount = Decimal(string: (amountControl.amount.replacingOccurrences(of: decimalNotation, with: ".")))!
            let timeStamp = Date()
            let cmd = CreateDonationCommand(mediumId: input.mediumId, amount: amount, userId: userId, timeStamp: timeStamp, collectId: "1")
            let donationId = try mediater.send(request: cmd)
            AppServices.shared.vibrate()
            if AppServices.shared.isServerReachable {
                let exportCommand = ExportDonationCommand(mediumId: input.mediumId, collectId: "1", amount: amount, userId: userId, timeStamp: timeStamp)
                try mediater.sendAsync(request: exportCommand) { isSuccessful in
                    if isSuccessful {
                        try? self.mediater.send(request: DeleteDonationCommand(objectId: donationId))
                        DispatchQueue.main.async {
                            try? (UIApplication.shared.delegate as? AppDelegate)?.coreDataContext.objectContext.save()
                        }
                    }
                }
                let route = DiscoverOrAmountOpenSafariRoute(donations: [Transaction(amount: amount, beaconId: input.mediumId, collectId: "0", timeStamp: timeStamp.toISOString(), userId: userId.uuidString)],
                    canShare: false,
                    userId: userId,
                    delegate: self,
                    collectGroupName: input.name)
                route.advertisement = try? mediater.send(request: GetRandomAdvertisementQuery(localeLanguageCode: Locale.current.languageCode ?? "en", localeRegionCode: Locale.current.regionCode ?? "eu", country: UserDefaults.standard.userExt?.country))
                try mediater.send(request: route, withContext: self)
            } else {
                try mediater.send(request: DiscoverOrAmountOpenOfflineSuccessRoute(collectGroupName: input.name), withContext: self)
            }
        } catch DonationError.amountTooHigh {
            displayAmountTooHigh()
            hideLoader()
        } catch DonationError.amountTooLow {
            showAmountTooLow()
            hideLoader()
        } catch SafariError.cannotOpenSafari {
            LogService.shared.error(message: "There was a problem opening Safari")
            hideLoader()
        }
        catch {}
    }
    
    @IBAction func addValue(sender: UIButton!) {
        if let tapped = sender.titleLabel?.text {
            // Return if tapped decimal button and amount is already decimal number
            if tapped.contains(decimalNotation.first!), amountControl.amount.contains(decimalNotation.first!) {
                return
            }
            // return if more than 2 numbers after comma or if length with comma is 9 (maximum number of digits with comma)
            else if let idx = amountControl.amount.index(of: decimalNotation),
                (amountControl.amount[idx...].count == 3
                    || amountControl.amount.count == 9) {
                return
            }
            // return if length is 6 (maximum number of digits)
            else if amountControl.amount.count == 6 {
                return
            }
            // return if amount is 0 and tapped is also 0
            else if ["","0"].contains(amountControl.amount), tapped == "0" {
                return
            }
            
            let newAmount = amountControl.amount == "0" && !tapped.contains(decimalNotation.first!) ? "" : amountControl.amount
            amountControl.amount = "\(newAmount)\(tapped)"
            
            checkAmount()
        }
    }
       
    @IBAction func clearValue(sender: UIButton!){
        amountControl.amount.removeLast()
        if amountControl.amount.count == 0 {
            amountControl.amount = "0";
        }
        checkAmount()
    }
    
    @IBAction func clearAll(_ sender: Any) {
        amountControl.amount = "0";
        checkAmount()
    }
            
    func clearAmounts() {
        amountControl.amount = "0";
        checkAmount()
    }
    
    @IBAction func presetButtonTapped(_ sender: Any) {
        guard let button = sender as? PresetButton else {
            return
        }
        amountControl.isPreset = true
        amountControl.amount = button.amount.text!
        checkAmount()
    }
    
    fileprivate func checkPresetButtons() {
        if UserDefaults.standard.hasPresetsSet == true {
            let fmt = NumberFormatter()
            fmt.minimumFractionDigits = 2
            fmt.minimumIntegerDigits = 1
            presetButton1.amount.text = fmt.string(from: UserDefaults.standard.amountPresets[0] as NSNumber)
            presetButton1.contentView.accessibilityLabel = fmt.string(from: UserDefaults.standard.amountPresets[0] as NSNumber)
            presetButton2.amount.text = fmt.string(from: UserDefaults.standard.amountPresets[1] as NSNumber)
            presetButton2.contentView.accessibilityLabel = fmt.string(from: UserDefaults.standard.amountPresets[1] as NSNumber)
            presetButton3.amount.text = fmt.string(from: UserDefaults.standard.amountPresets[2] as NSNumber)
            presetButton3.contentView.accessibilityLabel = fmt.string(from: UserDefaults.standard.amountPresets[2] as NSNumber)
            presetView.isHidden = false
        } else {
            presetView.isHidden = true
        }
    }
    
    fileprivate func showAmountTooLow() {

        let minimumAmount = UserDefaults.standard.currencySymbol == "£" ? "GivtMinimumAmountPond".localized : "GivtMinimumAmountEuro".localized
        let alert = UIAlertController(title: "AmountTooLow".localized,
                                      message: "GivtNotEnough".localized.replacingOccurrences(of: "{0}", with: minimumAmount.replacingOccurrences(of: ".", with: decimalNotation)), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
        }))
        self.present(alert, animated: true, completion:nil)
    }
    
    fileprivate func displayAmountTooHigh() {
        self.hideLoader()

        let alert = UIAlertController(
            title: "AmountTooHigh".localized,
            message: "AmountLimitExceeded".localized,
            preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "ChooseLowerAmount".localized, style: .default) { action in
        })
        
        alert.addAction(UIAlertAction(title: "ChangeGivingLimit".localized, style: .cancel, handler: { action in
            try? self.mediater.send(request: DiscoverOrAmountOpenChangeAmountLimitRoute(), withContext: self)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func checkAmount() {
        let parsedDecimal = Decimal(string: (amountControl.amount.replacingOccurrences(of: decimalNotation, with: ".")))!
        amountControl.amountLabel.textColor =
            parsedDecimal > Decimal(amountLimit) || (parsedDecimal > 0 && parsedDecimal < 0.25) ?
                UIColor.init(rgb: 0xb91a24).withAlphaComponent(0.5) :
                UIColor.init(rgb: 0xD2D1D9)
        amountControl.isValid = parsedDecimal <= Decimal(amountLimit) && parsedDecimal >= 0.25 || parsedDecimal == 0
        amountControl.activeMarker.backgroundColor = amountControl.isActive ? amountControl.isValid ? #colorLiteral(red: 0.2549019608, green: 0.7882352941, blue: 0.5529411765, alpha: 1) : #colorLiteral(red: 0.737254902, green: 0.09803921569, blue: 0.1137254902, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        giveButton.isEnabled = parsedDecimal <= Decimal(amountLimit) && parsedDecimal >= 0.25
    }
    
    internal func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        if let _ = URL.absoluteString.index(of: "cloud.givtapp.net") {
            try? self.mediater.send(request: FinalizeGivingRoute(), withContext: self)
        }
    }
}
