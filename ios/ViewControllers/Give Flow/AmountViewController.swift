//
//  AmViewController.swift
//  ios
//
//  Created by Lennie Stockman on 14/07/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import MaterialShowcase
import AppCenterCrashes
import AppCenterAnalytics
import SVProgressHUD
import Mixpanel

class AmountViewController: UIViewController, UIGestureRecognizerDelegate, MaterialShowcaseDelegate {
    
    private var log: LogService = LogService.shared
    private let slideFromRightAnimation = PresentFromRight()
    
    
    private var navigationManager: NavigationManager = NavigationManager.shared
    private var givtService:GivtManager!

    @IBOutlet var pageControl: UIView!
    @IBOutlet var calcView: UIView!
    
    @IBOutlet var btnRemove: CustomButton!
    @IBOutlet var btnNext: CustomButtonWithRightArrow!
    @IBOutlet var viewPresets: UIView!
    @IBOutlet var viewCalc: UIView!
    @IBOutlet var calcPresetsStackView: UIStackView!
    
    @IBOutlet var amountPresetOne: PresetButton!
    @IBOutlet var amountPresetTwo: PresetButton!
    @IBOutlet var amountPresetThree: PresetButton!
    @IBOutlet var addCollect: AddCollectButtonView!
    @IBOutlet weak var addCollectLabel: UILabel!
    
    @IBOutlet var btnComma: UIButton!
    
    @IBOutlet var stackCollections: UIStackView!
    
    @IBOutlet var collectOne: CollectionView!
    @IBOutlet var collectTwo: CollectionView!
    @IBOutlet var collectThree: CollectionView!
    var collectionViews: [CollectionView] = [CollectionView]()
    
    var currentCollect: CollectionView!
    
    private var pressedShortcutKey: Bool! = false
    
    var topAnchor: NSLayoutConstraint!
    var leadingAnchor: NSLayoutConstraint!
    var selectedAmount = 0
    
    private var amountLimit: Int {
        get {
            return UserDefaults.standard.amountLimit
        }
    }
    
    private var decimalNotation: String! = "," {
        didSet {
            btnComma.setTitle(decimalNotation, for: .normal)
            let fmt = NumberFormatter()
            fmt.minimumFractionDigits = 2
            fmt.minimumIntegerDigits = 1
            amountPresetOne.amount.text = fmt.string(from: UserDefaults.standard.amountPresets[0] as NSNumber)
            amountPresetOne.contentView.accessibilityLabel = fmt.string(from: UserDefaults.standard.amountPresets[0] as NSNumber)
            amountPresetTwo.amount.text = fmt.string(from: UserDefaults.standard.amountPresets[1] as NSNumber)
            amountPresetTwo.contentView.accessibilityLabel = fmt.string(from: UserDefaults.standard.amountPresets[1] as NSNumber)
            amountPresetThree.amount.text = fmt.string(from: UserDefaults.standard.amountPresets[2] as NSNumber)
            amountPresetThree.contentView.accessibilityLabel = fmt.string(from: UserDefaults.standard.amountPresets[2] as NSNumber)
        }
    }
    
    var nuOfCollectsShown: Int {
        var count = 0
        
        // get count of collectes shown
        for view in stackCollections.subviews as! [CollectionView] {
            if(!view.isHidden){
                count += 1
            }
        }
        return count
    }
    
    // Begin of system overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if(!UserDefaults.standard.hasPresetsSet!){
            calcPresetsStackView.removeArrangedSubview(viewPresets)
            viewPresets.isHidden = true
        }
        
        stackCollections.removeArrangedSubview(collectTwo)
        collectTwo.isHidden = true
        stackCollections.removeArrangedSubview(collectThree)
        collectThree.isHidden = true
        
        collectOne.deleteBtn.tag = 1
        collectOne.deleteBtn.addTarget(self, action: #selector(deleteCollect), for: UIControl.Event.touchUpInside)
        collectOne.collectLabel.text = NSLocalizedString("FirstCollect", comment: "")
        collectOne.collectLabel.isHidden = true
        collectOne.amountLabel.text = "0"
        
        
        collectTwo.deleteBtn.tag = 2
        collectTwo.deleteBtn.addTarget(self, action: #selector(deleteCollect), for: UIControl.Event.touchUpInside)
        collectTwo.collectLabel.text = NSLocalizedString("SecondCollect", comment: "")
        collectTwo.amountLabel.text = "0"
        
        collectThree.deleteBtn.tag = 3
        collectThree.deleteBtn.addTarget(self, action: #selector(deleteCollect), for: UIControl.Event.touchUpInside)
        collectThree.collectLabel.text = NSLocalizedString("ThirdCollect", comment: "")
        collectThree.amountLabel.text = "0"
        
        setActiveCollection(collectOne!)
        collectionViews.append(collectOne)
        
        let currency = CurrencyHelper.shared.getCurrencySymbol()
        let currencys = [collectOne.currencySign, collectTwo.currencySign, collectThree.currencySign, amountPresetOne.currency, amountPresetTwo.currency, amountPresetThree.currency]
        currencys.forEach { (c) in
            c?.text = currency
        }
        
        givtService = GivtManager.shared
        btnNext.labelText.text = NSLocalizedString("Next", comment: "Button to give")
        btnNext.labelText.adjustsFontSizeToFitWidth = true
        btnNext.accessibilityLabel = NSLocalizedString("Next", comment: "Button to give")
        
        addCollectLabel.text = NSLocalizedString("AddCollect", comment: "")
        addCollectLabel.adjustsFontSizeToFitWidth = true
        
        btnRemove.accessibilityLabel = NSLocalizedString("RemoveBtnAccessabilityLabel", comment: "")
        addCollect.accessibilityLabel = NSLocalizedString("AddCollect", comment: "")
        collectOne.deleteBtn.accessibilityLabel = NSLocalizedString("RemoveCollectButtonAccessibilityLabel", comment: "").replacingOccurrences(of: "{0}", with: NSLocalizedString("FirstCollect", comment: ""))
        collectTwo.deleteBtn.accessibilityLabel = NSLocalizedString("RemoveCollectButtonAccessibilityLabel", comment: "").replacingOccurrences(of: "{0}", with: NSLocalizedString("SecondCollect", comment: ""))
        collectThree.deleteBtn.accessibilityLabel = NSLocalizedString("RemoveCollectButtonAccessibilityLabel", comment: "").replacingOccurrences(of: "{0}", with: NSLocalizedString("ThirdCollect", comment: ""))
        
        NotificationCenter.default.addObserver(self, selector: #selector(presetsWillShow), name: .GivtAmountPresetsSet, object: nil)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(nuOfCollectsShown == 1){
            collectOne.deleteBtn.isHidden = true
            collectOne.collectLabel.isHidden = true
        }

        self.sideMenuController?.isLeftViewSwipeGestureEnabled = true
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        let country = try? Mediater.shared.send(request: GetCountryQuery())
        let locale = Locale(identifier: "\(Locale.current.languageCode!)-\(country!)")
        decimalNotation = locale.decimalSeparator! as String
        
        super.navigationController?.navigationBar.barTintColor = UIColor(rgb: 0xF5F5F5)
        navigationController?.navigationBar.isTranslucent = false
        let backItem = UIBarButtonItem()
        backItem.title = NSLocalizedString("Cancel", comment: "Annuleer")
        backItem.style = .plain
        backItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Avenir-Heavy", size: 18)!], for: .normal)
        btnNext.setBackgroundColor(color: UIColor.init(rgb: 0xE3E2E7), forState: .disabled)
        self.navigationItem.backBarButtonItem = backItem
        checkAmounts()
        
        log.info(message:"Mandate signed: " + String(UserDefaults.standard.mandateSigned))
        
        FeatureManager.shared.checkUpdateState(context: self)

        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        GivtManager.shared.getPublicMeta { (shouldShowGiftAid) in
            if let shouldAskForPermission = shouldShowGiftAid {
                if (UserDefaults.standard.mandateSigned && shouldAskForPermission){
                    let vc = UIStoryboard(name: "Personal", bundle: nil).instantiateViewController(withIdentifier: "GiftAidViewController") as! GiftAidViewController
                    vc.shouldAskForGiftAidPermission = shouldAskForPermission
                    LoginManager.shared.getUserExt { (userExtObject) in
                        SVProgressHUD.dismiss()
                        guard let userExt = userExtObject else {
                            let alert = UIAlertController(title: NSLocalizedString("RequestFailed", comment: ""), message: NSLocalizedString("CantFetchPersonalInformation", comment: ""), preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                                DispatchQueue.main.async {
                                    self.backPressed(self)
                                }
                            }))
                            return
                        }
                        vc.uExt = userExt
                        DispatchQueue.main.async {
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationManager.delegate = nil
    }
    
    // End of system overrides
    
    @IBAction func addCollect(_ sender: Any?) {
        
        var nuOfCollectsShown = self.nuOfCollectsShown
        
        if(collectOne.isHidden) {
            insertCollectAtPosition(collect: collectOne, position: 0)
            setActiveCollection(collectOne!)
            collectionViews.append(collectOne)
        } else if(collectTwo.isHidden){
            if(!collectOne.isHidden){
                collectOne.deleteBtn.isHidden = false
                collectOne.collectLabel.isHidden = false
            }
            insertCollectAtPosition(collect: collectTwo, position: 1)
            setActiveCollection(collectTwo!)
            collectionViews.append(collectTwo)
        } else if (collectThree.isHidden){
            insertCollectAtPosition(collect: collectThree, position: 2)
            setActiveCollection(collectThree!)
            collectionViews.append(collectThree)
        }
        
        nuOfCollectsShown = self.nuOfCollectsShown
        
        // if count off collects show is higher then 1 show all deletebuttons
        if nuOfCollectsShown > 1 {
            for view in stackCollections.subviews as! [CollectionView] {
                if(!view.isHidden){
                    view.deleteBtn.isHidden = false
                    view.collectLabel.isHidden = false
                }
            }
        }
        
        // if count of collects is higher or equal then one and les then 3 show the add button
        if nuOfCollectsShown >= 1 && nuOfCollectsShown < stackCollections.subviews.count {
            addCollect.isHidden = false
        } else {
            addCollect.isHidden = true
        }
        
        checkAmounts()
        
    }
    
    func insertCollectAtPosition(collect: CollectionView, position: Int){
        stackCollections.insertArrangedSubview(collect, at: position)
        collect.isHidden = false
        collect.deleteBtn.isHidden = false
    }
    
    @IBAction func setActiveCollection(_ sender: Any) {
        currentCollect = sender as? CollectionView
        collectionViews.filter { $0.tag != currentCollect.tag }.forEach { $0.isActive = false }
        currentCollect.isActive = true
        pressedShortcutKey = true
    }

    @IBAction func btnNextTouchDown(_ sender: Any) {
        btnNext.ogBGColor = #colorLiteral(red: 0.1098039216, green: 0.662745098, blue: 0.4235294118, alpha: 1)
    }
    
    @IBAction func btnNextTouchDragOutside(_ sender: Any) {
        btnNext.ogBGColor = #colorLiteral(red: 0.2529559135, green: 0.789002955, blue: 0.554667592, alpha: 1)
    }

    @IBAction func btnNext(_ sender: Any) {

        btnNext.ogBGColor = #colorLiteral(red: 0.2529559135, green: 0.789002955, blue: 0.554667592, alpha: 1)
        /* Check for the special crash secret */
        if Decimal(string: (collectOne.amountLabel.text!.replacingOccurrences(of: ",", with: ".")))! == 666
            && Decimal(string: (collectTwo.amountLabel.text!.replacingOccurrences(of: ",", with: ".")))! == 0.66
            && Decimal(string: (collectThree.amountLabel.text!.replacingOccurrences(of: ",", with: ".")))! == 66.6 {
            Crashes.generateTestCrash()
        }

        var numberOfZeroAmounts = 0
        for index in 0..<collectionViews.count {
            let parsedDecimal = Decimal(string: (self.collectionViews[index].amountLabel.text!.replacingOccurrences(of: ",", with: ".")))!

            if parsedDecimal > Decimal(UserDefaults.standard.amountLimit) {
                setActiveCollection(collectionViews[index])
                displayAmountLimitExceeded()
                return
            }

            if parsedDecimal > 0 && parsedDecimal < GivtManager.shared.minimumAmount {
                setActiveCollection(collectionViews[index])
                showAmountTooLow()
            }

            if parsedDecimal == 0 {
                numberOfZeroAmounts += 1
            }

            if numberOfZeroAmounts == collectionViews.count {
                showAmountTooLow()
                return
            }
        }


        givtService.setAmounts(amounts: [(collectOne.amountLabel.text?.decimalValue)!, (collectTwo.amountLabel.text?.decimalValue)!, (collectThree.amountLabel.text?.decimalValue)!])
        
        let hasPresetSet = UserDefaults.standard.hasPresetsSet ?? false
        let usedPreset:String = String( collectOne.isPreset && collectTwo.isPreset && collectThree.isPreset)
        Analytics.trackEvent("GIVING_STARTED", withProperties:["hasPresets": String(hasPresetSet), "usedPresets":usedPreset])
        Mixpanel.mainInstance().track(event: "GIVING_STARTED", properties: ["hasPresets": String(hasPresetSet), "usedPresets":usedPreset])
        
        if givtService.externalIntegration != nil && !givtService.externalIntegration!.wasShownAlready {
            let vc = UIStoryboard.init(name: "ExternalSuggestion", bundle: nil).instantiateInitialViewController() as! ExternalSuggestionViewController
            vc.providesPresentationContextTransitionStyle = true
            vc.definesPresentationContext = true
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            vc.closeAction = {
                let chooseContext = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChooseContextViewController") as! ChooseContextViewController
                self.navigationController?.pushViewController(chooseContext, animated: true)
            }
            self.navigationController?.present(vc, animated: true, completion: nil)
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "ChooseContextViewController") as! ChooseContextViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func addValue(sender:UIButton!) {
        let currentAmountLabel = currentCollect.amountLabel!
        currentCollect.isPreset = false
        if currentAmountLabel.text == "0" || pressedShortcutKey {
            currentAmountLabel.text = ""
        }
        
        if currentAmountLabel.text! == "" && (sender.titleLabel?.text?.contains(decimalNotation.first!))! {
            currentAmountLabel.text = "0";
        }
        
        if let idx = currentAmountLabel.text?.index(of: decimalNotation) {
            if( ((currentAmountLabel.text?[idx...].count)! == 3)) || ((sender.titleLabel?.text?.contains(decimalNotation.first!))!){
                return
            }
        }
        
        if (currentAmountLabel.text?.contains(decimalNotation.first!))! {
            if currentAmountLabel.text?.count == 9 {
                return
            }
        } else if currentAmountLabel.text?.count == 6 {
            return
        }
        currentAmountLabel.text = currentAmountLabel.text! + sender.currentTitle!;
        checkAmounts()
        pressedShortcutKey = false
    }
    
    @IBAction func addPresetValue(_ sender: Any) {
        
        let currentAmountLabel = currentCollect.amountLabel!
        currentCollect.isPreset = true
        let button = sender as! PresetButton
        
        currentAmountLabel.text = button.amount.text
        if button.amount.text!.contains(",") {
            let decimal = Decimal(string: button.amount.text!.replacingOccurrences(of: ",", with: "."))
            if decimal != 2.5 && decimal != 7.5 && decimal != 12.5 {
                self.log.info(message: "User used a custom amount preset")
                
            }
        } else if let decimal = Decimal(string: button.amount.text!) {
            if decimal != 2.5 && decimal != 7.5 && decimal != 12.5 {
                self.log.info(message: "User used a custom amount preset")
            }
        }
        checkAmounts()
        pressedShortcutKey = true
    }
    
    @IBAction func clearValue(sender: UIButton!){
        let currentAmountLabel = currentCollect.amountLabel!
        var amount: String = currentAmountLabel.text!
        if amount.count == 0 {
            checkAmounts()
            return
        }
        
        amount.remove(at: amount.index(before: amount.endIndex))
        currentAmountLabel.text! = amount
        if amount.count == 0 || pressedShortcutKey {
            currentAmountLabel.text = "0";
        }
        checkAmounts()
    }
    
    @IBAction func clearAll(_ sender: Any) {
        let currentAmountLabel = currentCollect.amountLabel!
        currentAmountLabel.text = "0";
        checkAmounts()
    }
    
    @objc func deleteCollect(sender: UIButton){
        switch sender.tag {
            case 1:
                collectOne.isPreset = true
                deleteCollectFromView(collect: collectOne)
                if (collectTwo.isHidden){
                    setActiveCollection(collectThree!)
                } else {
                    setActiveCollection(collectTwo!)
                }
            case 2:
                 collectTwo.isPreset = true
                deleteCollectFromView(collect: collectTwo)
                if (collectOne.isHidden){
                    setActiveCollection(collectThree!)
                } else {
                    setActiveCollection(collectOne!)
                }
            case 3:
                 collectThree.isPreset = true
                deleteCollectFromView(collect: collectThree)
                if (collectOne.isHidden){
                    setActiveCollection(collectTwo!)
                } else {
                    setActiveCollection(collectOne!)
            }
            default:
                return
        }
        
        let nuOfCollectsShown = self.nuOfCollectsShown
        
        // if count of collectes shown is one hide the delete button
        if nuOfCollectsShown == 1 {
            for view in stackCollections.subviews as! [CollectionView] {
                if(!view.isHidden){
                    view.deleteBtn.isHidden = true
                    view.collectLabel.isHidden = view.deleteBtn.tag == 1 ? true : false
                }
            }
        }
        
        // if count of collects is higher or equal then one and les then 3 show the add button
        if nuOfCollectsShown >= 1 && nuOfCollectsShown < stackCollections.subviews.count {
            addCollect.isHidden = false
        } else {
            addCollect.isHidden = true
        }
        checkAmounts()
    }
    func deleteCollectFromView(collect: CollectionView){
        stackCollections.removeArrangedSubview(collect)
        collect.isHidden = true
        collect.amountLabel.text = "0"
        collectionViews = collectionViews.filter { $0 != collect }
    }
    func selectFirstCollect(){
        setActiveCollection(collectionViews.first!)
    }
    
    func clearAmounts() {
        let emptyString = "0"
        for view in collectionViews {
            view.amountLabel.text? = emptyString
            if(view.tag != 1 && !view.isHidden){
                stackCollections.removeArrangedSubview(view)
                view.isHidden = true
            }
        }
        collectionViews.removeAll { $0.isHidden }
        
        if (collectOne.isHidden){
            addCollect(collectOne)
        }
        if (addCollect.isHidden){
            addCollect.isHidden = false
        }
        setActiveCollection(collectOne!)
        checkAmounts()
    }

    fileprivate func showAmountTooLow() {
        let minimumAmount = { () -> String in
            switch UserDefaults.standard.paymentType {
            case .BACSDirectDebit:
                return "GivtMinimumAmountPond".localized
            case .CreditCard:
                return "GivtMinimumAmountDollar".localized
            default:
                return "GivtMinimumAmountEuro".localized
            }
        }()
        let alert = UIAlertController(title: NSLocalizedString("AmountTooLow", comment: ""),
                                      message: NSLocalizedString("GivtNotEnough", comment: "").replacingOccurrences(of: "{0}", with: minimumAmount.replacingOccurrences(of: ".", with: decimalNotation)), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in  }))
        self.present(alert, animated: true, completion: {})
    }
    
    func displayAmountLimitExceeded() {
        let alert = UIAlertController(
            title: NSLocalizedString("AmountTooHigh", comment: ""),
            message: NSLocalizedString("AmountLimitExceeded", comment: ""),
            preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("ChooseLowerAmount", comment: ""), style: .default, handler: {
                action in
                self.checkAmounts()
            }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("ChangeGivingLimit", comment: ""), style: .cancel, handler: { action in
            LogService.shared.info(message: "User is opening giving limit")
            let vc = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "registration") as! RegNavigationController
            vc.startPoint = .amountLimit
            if (LoginManager.shared.isFullyRegistered || !UserDefaults.standard.isTempUser){
                vc.isRegistration = false
            } else {
                vc.isRegistration = true
            }
            vc.transitioningDelegate = self.slideFromRightAnimation
            vc.modalPresentationStyle = .fullScreen
            NavigationManager.shared.pushWithLogin(vc, context: self)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    func checkAmount(collection: CollectionView) {
        let parsedDecimal = Decimal(string: (collection.amountLabel.text!.replacingOccurrences(of: ",", with: ".")))!
        collection.amountLabel.textColor = parsedDecimal > Decimal(amountLimit) || (parsedDecimal > 0 && parsedDecimal < GivtManager.shared.minimumAmount) ? UIColor.init(rgb: 0xb91a24).withAlphaComponent(0.5) : UIColor.init(rgb: 0xD2D1D9)
        collection.isValid = parsedDecimal <= Decimal(amountLimit) && parsedDecimal >= GivtManager.shared.minimumAmount || parsedDecimal == 0
        collection.activeMarker.backgroundColor = collection.isActive ? collection.isValid ? #colorLiteral(red: 0.2549019608, green: 0.7882352941, blue: 0.5529411765, alpha: 1) : #colorLiteral(red: 0.737254902, green: 0.09803921569, blue: 0.1137254902, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
    }
    func checkAmounts() {
        collectionViews.forEach { checkAmount(collection: $0) }
        let countOfZeroAmounts = collectionViews.filter {
            !$0.isHidden
            && Decimal(string: $0.amountLabel.text!.replacingOccurrences(of: ",", with: "."))! == 0
        }.count
        btnNext.isEnabled = nuOfCollectsShown != countOfZeroAmounts
    }

    @objc func presetsWillShow(notification: Notification){
        if(!viewPresets.isHidden){
            calcPresetsStackView.removeArrangedSubview(viewPresets)
            viewPresets.isHidden = true
        } else {
            calcPresetsStackView.insertArrangedSubview(viewPresets, at: 0)
            viewPresets.isHidden = false
        }
    }
}
