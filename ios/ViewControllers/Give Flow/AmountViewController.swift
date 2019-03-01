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
    private let slideFromRightAnimation = PresentFromRight()
    
    private var navigiationManager: NavigationManager = NavigationManager.shared
    private var givtService:GivtManager!

    @IBOutlet var pageControl: UIView!
    @IBOutlet var calcView: UIView!
    
    @IBOutlet var menu: UIBarButtonItem!
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
    @IBOutlet weak var lblTitle: UINavigationItem!
    @IBOutlet weak var screenTitle: UILabel!
    
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
    private var _cameFromFAQ: Bool = false
    
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
            amountPresetTwo.amount.text = fmt.string(from: UserDefaults.standard.amountPresets[1] as NSNumber)
            amountPresetThree.amount.text = fmt.string(from: UserDefaults.standard.amountPresets[2] as NSNumber)
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
        collectOne.deleteBtn.addTarget(self, action: #selector(deleteCollect), for: UIControlEvents.touchUpInside)
        collectOne.collectLabel.text = NSLocalizedString("FirstCollect", comment: "")
        collectOne.amountLabel.text = "0"
        
        collectTwo.deleteBtn.tag = 2
        collectTwo.deleteBtn.addTarget(self, action: #selector(deleteCollect), for: UIControlEvents.touchUpInside)
        collectTwo.collectLabel.text = NSLocalizedString("SecondCollect", comment: "")
        collectTwo.amountLabel.text = "0"
        
        collectThree.deleteBtn.tag = 3
        collectThree.deleteBtn.addTarget(self, action: #selector(deleteCollect), for: UIControlEvents.touchUpInside)
        collectThree.collectLabel.text = NSLocalizedString("ThirdCollect", comment: "")
        collectThree.amountLabel.text = "0"
        
        setActiveCollection(collectOne)
        collectionViews.append(collectOne)
        
        let currency = UserDefaults.standard.currencySymbol
        let currencys = [collectOne.currencySign, collectTwo.currencySign, collectThree.currencySign, amountPresetOne.currency, amountPresetTwo.currency, amountPresetThree.currency]
        currencys.forEach { (c) in
            c?.text = currency
        }
        
        givtService = GivtManager.shared
        btnNext.labelText.text = NSLocalizedString("Next", comment: "Button to give")
        btnNext.labelText.adjustsFontSizeToFitWidth = true
        btnNext.accessibilityLabel = NSLocalizedString("Next", comment: "Button to give")
        
        screenTitle.text = NSLocalizedString("Amount", comment: "Title on the AmountPage")
        addCollectLabel.text = NSLocalizedString("AddCollect", comment: "")
        addCollectLabel.adjustsFontSizeToFitWidth = true
        lblTitle.title = ""
        
        menu.accessibilityLabel = "Menu"
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkBadges), name: .GivtBadgeNumberDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presetsWillShow), name: .GivtAmountPresetsSet, object: nil)

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
        btnNext.setBackgroundColor(color: UIColor.init(rgb: 0xE3E2E7), forState: .disabled)
        self.navigationItem.backBarButtonItem = backItem
        checkAmounts()
        
        log.info(message:"Mandate signed: " + String(UserDefaults.standard.mandateSigned))
        
        FeatureManager.shared.checkUpdateState(context: self)
        
        menu.image = BadgeService.shared.hasBadge() ? #imageLiteral(resourceName: "menu_badge") : #imageLiteral(resourceName: "menu_base")
        
        if self.presentedViewController?.restorationIdentifier == "FAQViewController" {
            self._cameFromFAQ = true
        }
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "pg_give_first"))
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigiationManager.delegate = self
        
        if (self.sideMenuController?.isLeftViewHidden)! && !self._cameFromFAQ {
            navigiationManager.finishRegistrationAlert(self)
        }
        
        self._cameFromFAQ = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigiationManager.delegate = nil
    }
    
    // End of system overrides
    
    @IBAction func addCollect(_ sender: Any) {
        
        var nuOfCollectsShown = self.nuOfCollectsShown
        
        if(collectOne.isHidden) {
            insertCollectAtPosition(collect: collectOne, position: 0)
            setActiveCollection(collectOne)
            collectionViews.append(collectOne)
        } else if(collectTwo.isHidden){
            insertCollectAtPosition(collect: collectTwo, position: 1)
            setActiveCollection(collectTwo)
            collectionViews.append(collectTwo)
        } else if (collectThree.isHidden){
            insertCollectAtPosition(collect: collectThree, position: 2)
            setActiveCollection(collectThree)
            collectionViews.append(collectThree)
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
    
    func insertCollectAtPosition(collect: CollectionView, position: Int){
        stackCollections.insertArrangedSubview(collect, at: position)
        collect.isHidden = false
        collect.deleteBtn.isHidden = false
    }
    
    @IBAction func setActiveCollection(_ sender: Any) {
        currentCollect = sender as? CollectionView
        collectOne.active = false
        collectTwo.active = false
        collectThree.active = false
        currentCollect.active = true
    }

    @IBAction func btnNext(_ sender: Any) {
        var numberOfZeroAmounts = 0
        for index in 0..<collectionViews.count {
            let parsedDecimal = Decimal(string: (self.collectionViews[index].amountLabel.text!.replacingOccurrences(of: ",", with: ".")))!
            
            if parsedDecimal > Decimal(UserDefaults.standard.amountLimit) {
                setActiveCollection(collectionViews[index])
                displayAmountLimitExceeded()
                return
            }
            
            if parsedDecimal  > 0 && parsedDecimal < 0.50 {
                setActiveCollection(collectionViews[index])
                showAmountTooLow()
                return
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
    
    func willResume(sender: NavigationManager) {
        if ((self.presentedViewController as? UIAlertController) == nil) {
            if (self.sideMenuController?.isLeftViewHidden)! && !self._cameFromFAQ {
                navigiationManager.finishRegistrationAlert(self)
            }
            self._cameFromFAQ = false
        }
    }
    
    @objc func deleteCollect(sender: UIButton){
        switch sender.tag {
            case 1:
                deleteCollectFromView(collect: collectOne)
                if (collectTwo.isHidden){
                    setActiveCollection(collectThree)
                } else {
                    setActiveCollection(collectTwo)
                }
            case 2:
                deleteCollectFromView(collect: collectTwo)
                if (collectOne.isHidden){
                    setActiveCollection(collectThree)
                } else {
                    setActiveCollection(collectOne)
                }
            case 3:
                deleteCollectFromView(collect: collectThree)
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
    func deleteCollectFromView(collect: CollectionView){
        stackCollections.removeArrangedSubview(collect)
        collect.isHidden = true
        collect.amountLabel.text = "0"
        collectionViews = collectionViews.filter { $0 != collect }
    }
    func selectFirstCollect(){
        setActiveCollection(collectionViews.first!)
    }
    @objc func checkBadges(notification:Notification) {
        DispatchQueue.main.async {
            self.menu.image = BadgeService.shared.hasBadge() ? #imageLiteral(resourceName: "menu_badge") : #imageLiteral(resourceName: "menu_base")
        }
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
        if (collectOne.isHidden){
            addCollect(collectOne)
        }
        if (addCollect.isHidden){
            addCollect.isHidden = false
        }
        setActiveCollection(collectOne)
        checkAmounts()
    }

    fileprivate func showAmountTooLow() {
        let minimumAmount = UserDefaults.standard.currencySymbol == "£" ? NSLocalizedString("GivtMinimumAmountPond", comment: "") : NSLocalizedString("GivtMinimumAmountEuro", comment: "")
        let alert = UIAlertController(title: NSLocalizedString("AmountTooLow", comment: ""), message: NSLocalizedString("GivtNotEnough", comment: "").replacingOccurrences(of: "{0}", with: minimumAmount.replacingOccurrences(of: ".", with: decimalNotation)), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in  }))
        self.present(alert, animated: true, completion: {})
    }
    
    func displayAmountLimitExceeded() {
        let alert = UIAlertController(
            title: NSLocalizedString("AmountTooHigh", comment: ""),
            message: NSLocalizedString("AmountLimitExceeded", comment: ""),
            preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ChooseLowerAmount", comment: ""), style: .default, handler: {
            action in
            self.currentCollect.amountLabel.text = String(UserDefaults.standard.amountLimit)
            self.checkAmounts()
        }))
        if (LoginManager.shared.isFullyRegistered){
            alert.addAction(UIAlertAction(title: NSLocalizedString("ChangeGivingLimit", comment: ""), style: .cancel, handler: { action in
                LogService.shared.info(message: "User is opening giving limit")
                let vc = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "registration") as! RegNavigationController
                vc.startPoint = .amountLimit
                vc.isRegistration = false
                vc.transitioningDelegate = self.slideFromRightAnimation
                NavigationManager.shared.pushWithLogin(vc, context: self)
            }))
        }
        self.present(alert, animated: true, completion: nil)
    }

    func checkAmounts() {
        var amountsUnder50C = 0
        for index in 0..<collectionViews.count {
            let parsedDecimal = Decimal(string: (collectionViews[index].amountLabel.text!.replacingOccurrences(of: ",", with: ".")))!
            if parsedDecimal < 0.50 {
                amountsUnder50C += 1
            }
            btnNext.isEnabled = amountsUnder50C != collectionViews.count
        }

        currentCollect.amountLabel.textColor = Decimal(string: (currentCollect.amountLabel.text!.replacingOccurrences(of: ",", with: ".")))! > Decimal(amountLimit) ? UIColor.init(rgb: 0xb91a24).withAlphaComponent(0.5) : UIColor.init(rgb: 0xD2D1D9)
        currentCollect.isInValid = Decimal(string: (currentCollect.amountLabel.text!.replacingOccurrences(of: ",", with: ".")))! > Decimal(amountLimit)
    }

    let slideAnimator = CustomPresentModalAnimation()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "faq" {
            let destination = segue.destination
            destination.transitioningDelegate = slideAnimator
        }
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
