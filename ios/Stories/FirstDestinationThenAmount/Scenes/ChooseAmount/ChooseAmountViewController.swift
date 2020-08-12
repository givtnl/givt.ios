//
//  SelectAmountViewController.swift
//  ios
//
//  Created by Mike Pattyn on 14/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import MaterialShowcase
import AppCenterCrashes
import AppCenterAnalytics
import SVProgressHUD

class ChooseAmountViewController: UIViewController, UIGestureRecognizerDelegate {
    private var mediater: MediaterWithContextProtocol = Mediater.shared

    var input: OpenChooseAmountRoute!
    
    @IBOutlet var giveButton: CustomButtonWithRightArrow!
    @IBOutlet var removeButton: CustomButton!
    @IBOutlet var commaButton: UIButton!
    @IBOutlet weak var screenTitle: UILabel!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet weak var amountControl: CollectionView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
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
        
        giveButton.labelText.text = NSLocalizedString("Give", comment: "Button to give")
        giveButton.labelText.adjustsFontSizeToFitWidth = true
        giveButton.accessibilityLabel = NSLocalizedString("Give", comment: "Button to give")
        
        screenTitle.text = NSLocalizedString("Amount", comment: "Title on the AmountPage")
        navigationTitle.title = ""
        
        removeButton.accessibilityLabel = NSLocalizedString("RemoveBtnAccessabilityLabel", comment: "")
        
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
        
        checkAmount()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        decimalNotation = NSLocale.current.decimalSeparator! as String

        navigationItem.titleView = UIImageView(image: UIImage(named: "pg_give_second"))
        navigationItem.accessibilityLabel = NSLocalizedString("ProgressBarStepTwo", comment: "")
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func backButton(_ sender: Any) {
        try? mediater.send(request: BackToChooseDestinationRoute(amount: amountControl.amount), withContext: self)
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
            if !AppServices.shared.isServerReachable {
                try? mediater.send(request: NoInternetAlert(), withContext: self)
                return
            }
            
            showLoader()
            let user = try mediater.send(request: GetLocalUserConfiguration())
            guard let userId = user.userId else {
                LogService.shared.error(message: "Trying to donate without valid userId")
                return
            }
            let amount = Decimal(string: (amountControl.amount.replacingOccurrences(of: decimalNotation, with: ".")))!
            let timeStamp = Date()
            let cmd = CreateDonationCommand(mediumId: input.mediumId, amount: amount, userId: userId, timeStamp: timeStamp)
            let donationId = try mediater.send(request: cmd)
            let exportCommand = ExportDonationCommand(mediumId: input.mediumId, amount: amount, userId: userId, timeStamp: timeStamp)
            try mediater.sendAsync(request: exportCommand) { isSuccessful in
                if isSuccessful {
                    try? self.mediater.send(request: DeleteDonationCommand(objectId: donationId))
                }
            }
            AppServices.shared.vibrate()
            hideLoader()
            try mediater.sendAsync(request: GoToSafariRoute(donations: [Transaction(amount: amount, beaconId: input.mediumId, collectId: "0", timeStamp: timeStamp.toISOString(), userId: userId.uuidString)],
                                                       canShare: false,
                                                       userId: userId,
                                                       collectGroupName: input.name),
                                   withContext: self)
            {
                usleep(500000)
                try? self.mediater.send(request: FinalizeGivingRoute(), withContext: self)
            }
        } catch DonationError.amountTooHigh {
            displayAmountTooHigh()
        } catch DonationError.amountTooLow {
            showAmountTooLow()
        } catch SafariError.cannotOpenSafari {
            LogService.shared.error(message: "There was a problem opening Safari")
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

    fileprivate func showAmountTooLow() {
        let minimumAmount = UserDefaults.standard.currencySymbol == "£" ? NSLocalizedString("GivtMinimumAmountPond", comment: "") : NSLocalizedString("GivtMinimumAmountEuro", comment: "")
        let alert = UIAlertController(title: NSLocalizedString("AmountTooLow", comment: ""),
                                      message: NSLocalizedString("GivtNotEnough", comment: "").replacingOccurrences(of: "{0}", with: minimumAmount.replacingOccurrences(of: ".", with: decimalNotation)), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in  }))
        self.present(alert, animated: true, completion: {})
    }
    
    fileprivate func displayAmountTooHigh() {
        let alert = UIAlertController(
            title: NSLocalizedString("AmountTooHigh", comment: ""),
            message: NSLocalizedString("AmountLimitExceeded", comment: ""),
            preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("ChooseLowerAmount", comment: ""), style: .default) { action in })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("ChangeGivingLimit", comment: ""), style: .cancel, handler: { action in
            try? self.mediater.send(request: ChangeAmountLimitRoute(), withContext: self)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func checkAmount() {
        let parsedDecimal = Decimal(string: (amountControl.amount.replacingOccurrences(of: decimalNotation, with: ".")))!
        amountControl.amountLabel.textColor =
            parsedDecimal > Decimal(amountLimit) || (parsedDecimal > 0 && parsedDecimal < 0.50) ?
                UIColor.init(rgb: 0xb91a24).withAlphaComponent(0.5) :
                UIColor.init(rgb: 0xD2D1D9)
        amountControl.isValid = parsedDecimal <= Decimal(amountLimit) && parsedDecimal >= 0.50 || parsedDecimal == 0
        amountControl.activeMarker.backgroundColor = amountControl.isActive ? amountControl.isValid ? #colorLiteral(red: 0.2549019608, green: 0.7882352941, blue: 0.5529411765, alpha: 1) : #colorLiteral(red: 0.737254902, green: 0.09803921569, blue: 0.1137254902, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        giveButton.isEnabled = amountControl.isValid
    }
}