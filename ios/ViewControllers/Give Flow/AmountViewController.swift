//
//  AmViewController.swift
//  ios
//
//  Created by Lennie Stockman on 14/07/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import MaterialShowcase

class AmountViewController: UIViewController, UIGestureRecognizerDelegate, NavigationManagerDelegate, MaterialShowcaseDelegate {
    private var log: LogService = LogService.shared
    @IBOutlet var widthConstraint: NSLayoutConstraint!
    @IBOutlet var collectionView: UIView!
    private let slideFromRightAnimation = PresentFromRight()
    
    private var navigiationManager: NavigationManager = NavigationManager.shared
    @IBOutlet var menu: UIBarButtonItem!
    
    @IBOutlet var btnNext: CustomButton!
    @IBAction func btnNext(_ sender: Any) {
        calcPresetsStackView.removeArrangedSubview(viewPresets)
    }
    @IBOutlet var viewPresets: UIView!
    @IBOutlet var viewCalc: UIView!
    
    @IBOutlet var calcPresetsStackView: UIStackView!
    
    var topAnchor: NSLayoutConstraint!
    var leadingAnchor: NSLayoutConstraint!
    
    private var amountLimit: Int {
        get {
            return UserDefaults.standard.amountLimit
        }
    }
    var selectedAmount = 0
    var numberOfCollects = 1
//    var amount: String {
//        get {
//            return amountLabels[selectedAmount].text!
//        }
//        set {
//            amountLabels[selectedAmount].text = amount
//        }
//    }
    
    func willResume(sender: NavigationManager) {
        if ((self.presentedViewController as? UIAlertController) == nil) {
            if (self.sideMenuController?.isLeftViewHidden)! && !self._cameFromFAQ {
                navigiationManager.finishRegistrationAlert(self)
            }
            
            self._cameFromFAQ = false
        }
    }
    
    private var pressedShortcutKey: Bool! = false
    private var decimalNotation: String! = "," {
        didSet {
            btnComma.setTitle(decimalNotation, for: .normal)
            let fmt = NumberFormatter()
            fmt.minimumFractionDigits = 2
            fmt.minimumIntegerDigits = 1
            amountPresetOne.amount.text = fmt.string(from: UserDefaults.standard.amountPresets[0] as NSNumber)
            amountPresetTwo.amount.text = fmt.string(from: UserDefaults.standard.amountPresets[1] as NSNumber)
            amountPresetThree.amount.text = fmt.string(from: UserDefaults.standard.amountPresets[2] as NSNumber)
        }
    }


    @IBOutlet var amountPresetOne: PresetButton!
    @IBOutlet var amountPresetTwo: PresetButton!
    @IBOutlet var amountPresetThree: PresetButton!
    
    @IBOutlet var btnComma: UIButton!
    @IBOutlet weak var lblTitle: UINavigationItem!
    @IBOutlet weak var btnGive: CustomButton!
    @IBOutlet var leadingCtrCalc: NSLayoutConstraint!
    
    @IBOutlet var stackCollections: UIStackView!

    @IBOutlet var collectOne: CollectionView!
    @IBOutlet var collectTwo: CollectionView!
    @IBOutlet var collectThree: CollectionView!
    
    var currentAmount: CollectionView!
    
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
    
    @IBOutlet var addCollect: StripedBorderView!
    func insertCollectAtPosition(collect: CollectionView, position: Int){
        stackCollections.insertArrangedSubview(collect, at: position)
        collect.isHidden = false
        collect.deleteBtn.isHidden = false
    }

    @IBAction func addCollect(_ sender: Any) {
        
        var nuOfCollectsShown = self.nuOfCollectsShown
        
        if(collectOne.isHidden) {
            insertCollectAtPosition(collect: collectOne, position: 0)
            setActiveCollection(collectOne)
        } else if(collectTwo.isHidden){
            insertCollectAtPosition(collect: collectTwo, position: 1)
            setActiveCollection(collectTwo)
        } else if (collectThree.isHidden){
            insertCollectAtPosition(collect: collectThree, position: 2)
            setActiveCollection(collectThree)
        }
        
        nuOfCollectsShown = self.nuOfCollectsShown

        // if count off collects show is higher then 1 show all deletebuttons
        if nuOfCollectsShown > 1 {
            for view in stackCollections.subviews as! [CollectionView] {
                if(!view.isHidden){
                    view.deleteBtn.isHidden = false
                }
            }
        }
        
        // if count of collects is higher or equal then one and les then 3 show the add button
        if nuOfCollectsShown >= 1 && nuOfCollectsShown < stackCollections.subviews.count {
            addCollect.isHidden = false
        } else {
            addCollect.isHidden = true
        }
    }
    private var givtService:GivtManager!
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    @objc func deleteCollect(sender: UIButton){
        switch sender.tag {
            case 1:
                stackCollections.removeArrangedSubview(collectOne)
                collectOne.isHidden = true
                if (collectTwo.isHidden){
                    setActiveCollection(collectThree)
                } else {
                    setActiveCollection(collectTwo)
                }
            case 2:
                stackCollections.removeArrangedSubview(collectTwo)
                collectTwo.isHidden = true
                if (collectOne.isHidden){
                    setActiveCollection(collectThree)
                } else {
                    setActiveCollection(collectOne)
                }
            case 3:
                stackCollections.removeArrangedSubview(collectThree)
                collectThree.isHidden = true
                if (collectOne.isHidden){
                    setActiveCollection(collectTwo)
                } else {
                    setActiveCollection(collectOne)
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
                }
            }
        }
        
        // if count of collects is higher or equal then one and les then 3 show the add button
        if nuOfCollectsShown >= 1 && nuOfCollectsShown < stackCollections.subviews.count {
            addCollect.isHidden = false
        } else {
            addCollect.isHidden = true
        }
    }
    @IBOutlet var pageControl: UIView!
    @IBOutlet var calcView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        stackCollections.removeArrangedSubview(collectTwo)
        collectTwo.isHidden = true
        stackCollections.removeArrangedSubview(collectThree)
        collectThree.isHidden = true
        
        collectOne.deleteBtn.tag = 1
        collectOne.deleteBtn.addTarget(self, action: #selector(deleteCollect), for: UIControlEvents.touchUpInside)
        collectOne.collectLabel.text = "1ste collecte"
        collectOne.amountLabel.text = "0"
        
        collectTwo.deleteBtn.tag = 2
        collectTwo.deleteBtn.addTarget(self, action: #selector(deleteCollect), for: UIControlEvents.touchUpInside)
        collectTwo.collectLabel.text = "2de collecte"
        collectTwo.amountLabel.text = "0"
        
        collectThree.deleteBtn.tag = 3
        collectThree.deleteBtn.addTarget(self, action: #selector(deleteCollect), for: UIControlEvents.touchUpInside)
        collectThree.collectLabel.text = "3de collecte"
        collectThree.amountLabel.text = "0"
    
        let currency = UserDefaults.standard.currencySymbol
        let currencys = [collectOne.currencySign, collectTwo.currencySign, collectThree.currencySign, amountPresetOne.currency, amountPresetTwo.currency, amountPresetThree.currency]
        currencys.forEach { (c) in
            c?.text = currency
        }
        
        givtService = GivtManager.shared
        btnNext.setTitle(NSLocalizedString("Next", comment: "Button to give"), for: UIControlState.normal)
        btnNext.accessibilityLabel = NSLocalizedString("Next", comment: "Button to give")
        
        setActiveCollection(collectOne)
        lblTitle.title = NSLocalizedString("Amount", comment: "Title on the AmountPage")

        menu.accessibilityLabel = "Menu"

        
        NotificationCenter.default.addObserver(self, selector: #selector(checkBadges), name: .GivtBadgeNumberDidChange, object: nil)
    }
    
    @objc func checkBadges(notification:Notification) {
        DispatchQueue.main.async {
            self.menu.image = BadgeService.shared.hasBadge() ? #imageLiteral(resourceName: "menu_badge") : #imageLiteral(resourceName: "menu_base")
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = true
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        decimalNotation = NSLocale.current.decimalSeparator! as String
        super.navigationController?.navigationBar.barTintColor = UIColor(rgb: 0xF5F5F5)
        navigationController?.navigationBar.isTranslucent = false
        let backItem = UIBarButtonItem()
        backItem.title = NSLocalizedString("Cancel", comment: "Annuleer")
        backItem.style = .plain
        backItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 18)!], for: .normal)
//        btnGive.setBackgroundColor(color: UIColor.init(rgb: 0xE3E2E7), forState: .disabled)
        self.navigationItem.backBarButtonItem = backItem
//        checkAmounts()
        
        log.info(message:"Mandate signed: " + String(UserDefaults.standard.mandateSigned))
        
        FeatureManager.shared.checkUpdateState(context: self)
        
        menu.image = BadgeService.shared.hasBadge() ? #imageLiteral(resourceName: "menu_badge") : #imageLiteral(resourceName: "menu_base")
        
        if self.presentedViewController?.restorationIdentifier == "FAQViewController" {
            self._cameFromFAQ = true
        }
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.init(rgb: 0x2E2957), NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 18)!]
    }
    
    private var _cameFromFAQ: Bool = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigiationManager.delegate = self
 
        if (self.sideMenuController?.isLeftViewHidden)! && !self._cameFromFAQ {
            navigiationManager.finishRegistrationAlert(self)
        }
        
        self._cameFromFAQ = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigiationManager.delegate = nil
        

    }
    
    @IBAction func addValue(sender:UIButton!) {
        var currentAmountLabel = currentAmount.amountLabel!
        
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
//        checkAmounts()
        pressedShortcutKey = false
    }
    

    @IBAction func setActiveCollection(_ sender: Any) {
        currentAmount = sender as? CollectionView
        collectOne.active = false
        collectTwo.active = false
        collectThree.active = false
        currentAmount.active = true
    }
    
    @IBAction func addShortcutValue(_ sender: Any) {
        var currentAmountLabel = currentAmount.amountLabel!
        
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
        //        checkAmounts()
        pressedShortcutKey = true
    }
    
    @IBAction func clearValue(sender: UIButton!){
        let currentAmountLabel = currentAmount.amountLabel!
        var amount: String = currentAmountLabel.text!
        if amount.count == 0 {
//            checkAmounts()
            return
        }

        amount.remove(at: amount.index(before: amount.endIndex))
        currentAmountLabel.text! = amount
        if amount.count == 0 || pressedShortcutKey {
            currentAmountLabel.text = "0";
        }
        //checkAmounts()

    }

    @IBAction func clearAll(_ sender: Any) {
        var currentAmountLabel = currentAmount.amountLabel!
        currentAmountLabel.text = "0";
        //checkAmounts()
    }
    
//    func clearAmounts() {
//        let emptyString = "0"
//        self.amountLabel.text? = emptyString
//        self.amountLabel2.text? = emptyString
//        self.amountLabel3.text? = emptyString
//        removeCollection()
//        removeCollection()
//        checkAmounts()
//    }

//    fileprivate func showAmountTooLow() {
//        let minimumAmount = UserDefaults.standard.currencySymbol == "£" ? NSLocalizedString("GivtMinimumAmountPond", comment: "") : NSLocalizedString("GivtMinimumAmountEuro", comment: "")
//        let alert = UIAlertController(title: NSLocalizedString("AmountTooLow", comment: ""), message: NSLocalizedString("GivtNotEnough", comment: "").replacingOccurrences(of: "{0}", with: minimumAmount.replacingOccurrences(of: ".", with: decimalNotation)), preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in  }))
//        self.present(alert, animated: true, completion: {})
//    }
    
//    @IBAction func actionGive(_ sender: Any) {
//        var numberOfZeroAmounts = 0
//        for index in 0..<numberOfCollects {
//            let parsedDecimal = Decimal(string: (amountLabels[index].text!.replacingOccurrences(of: ",", with: ".")))!
//
//            if parsedDecimal > Decimal(UserDefaults.standard.amountLimit) {
//                selectView(index)
//                displayAmountLimitExceeded()
//                return
//            }
//
//            if parsedDecimal  > 0 && parsedDecimal < 0.50 {
//                selectView(index)
//                showAmountTooLow()
//                return
//            }
//
//            if parsedDecimal == 0 {
//                numberOfZeroAmounts += 1
//            }
//
//            if numberOfZeroAmounts == numberOfCollects {
//                showAmountTooLow()
//                return
//            }
//        }
//
//
//        givtService.setAmounts(amounts: [(amountLabels[0].text?.decimalValue)!, (amountLabels[1].text?.decimalValue)!, (amountLabels[2].text?.decimalValue)!])
//
//        if givtService.externalIntegration != nil && !givtService.externalIntegration!.wasShownAlready {
//            let vc = UIStoryboard.init(name: "ExternalSuggestion", bundle: nil).instantiateInitialViewController() as! ExternalSuggestionViewController
//            vc.providesPresentationContextTransitionStyle = true
//            vc.definesPresentationContext = true
//            vc.modalPresentationStyle = .overFullScreen
//            vc.modalTransitionStyle = .crossDissolve
//            vc.closeAction = {
//                let chooseContext = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChooseContextViewController") as! ChooseContextViewController
//                self.navigationController?.pushViewController(chooseContext, animated: true)
//            }
//            self.navigationController?.present(vc, animated: true, completion: nil)
//        } else {
//            let vc = storyboard?.instantiateViewController(withIdentifier: "ChooseContextViewController") as! ChooseContextViewController
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//     }
    
//    func displayAmountLimitExceeded() {
//        let alert = UIAlertController(
//            title: NSLocalizedString("AmountTooHigh", comment: ""),
//            message: NSLocalizedString("AmountLimitExceeded", comment: ""),
//            preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: NSLocalizedString("ChooseLowerAmount", comment: ""), style: .default, handler: {
//            action in
//            self.currentAmountLabel.text = String(UserDefaults.standard.amountLimit)
//            self.checkAmounts()
//        }))
//        if (LoginManager.shared.isFullyRegistered){
//            alert.addAction(UIAlertAction(title: NSLocalizedString("ChangeGivingLimit", comment: ""), style: .cancel, handler: { action in
//                LogService.shared.info(message: "User is opening giving limit")
//                let vc = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "registration") as! RegNavigationController
//                vc.startPoint = .amountLimit
//                vc.isRegistration = false
//                vc.transitioningDelegate = self.slideFromRightAnimation
//                NavigationManager.shared.pushWithLogin(vc, context: self)
//            }))
//        }
//        self.present(alert, animated: true, completion: nil)
//    }

//    func checkAmounts() {
//        var amountsUnder50C = 0
//        for index in 0..<numberOfCollects {
//            let parsedDecimal = Decimal(string: (amountLabels[index].text!.replacingOccurrences(of: ",", with: ".")))!
//            if parsedDecimal < 0.50 {
//                amountsUnder50C += 1
//            }
//            btnNext.isEnabled = amountsUnder50C != numberOfCollects
//        }
//
//        currentAmountLabel.textColor = Decimal(string: (currentAmountLabel.text!.replacingOccurrences(of: ",", with: ".")))! > Decimal(amountLimit) ? UIColor.init(rgb: 0xb91a24).withAlphaComponent(0.5) : UIColor.init(rgb: 0xD2D1D9)
//    }
//
//    func showShowcase(message: String, targetView: UIView) {
//        let showCase = MaterialShowcase()
//        showCase.delegate = self
//        showCase.primaryText = message
//        showCase.secondaryText = NSLocalizedString("CancelFeatureMessage", comment: "")
//
//        DispatchQueue.main.async {
//            showCase.setTargetView(view: targetView) // always required to set targetView
//            showCase.shouldSetTintColor = false
//            showCase.backgroundPromptColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
//            showCase.show(completion: nil)
//        }
//    }

//    let slideAnimator = CustomPresentModalAnimation()
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "faq" {
//            let destination = segue.destination
//            destination.transitioningDelegate = slideAnimator
//        }
//    }
    
//    @IBAction func returnFromSegue(sender: UIStoryboardSegue) {
//
//    }
    
}
