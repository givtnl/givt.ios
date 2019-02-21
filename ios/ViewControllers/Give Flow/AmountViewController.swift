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
//    @IBOutlet var containerCollection: UIView!
//    @IBOutlet var amountLabel3: UILabel!
//    @IBOutlet var amountLabel2: UILabel!
//    @IBOutlet var leftSpacerView: UIView!
//    @IBOutlet var rightSpacerView: UIView!
//    @IBOutlet var firstView: UIView!
//    @IBOutlet var firstLine: UIView!
//    @IBOutlet var firstEuro: UILabel!
//    @IBOutlet var secondLine: UIView!
//    @IBOutlet var secondEuro: UILabel!
//    @IBOutlet var thirdLine: UIView!
//    @IBOutlet var thirdEuro: UILabel!
//    @IBOutlet var secondView: UIView!
//    @IBOutlet var thirdView: UIView!
//    @IBOutlet var collectionButton: UIButton!

    
    @IBOutlet var btnNext: CustomButton!
    @IBAction func btnNext(_ sender: Any) {
        calcPresetsStackView.removeArrangedSubview(viewPresets)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
//            // Code you want to be delayed
//            self.calcPresetsStackView.insertArrangedSubview(self.viewPresets, at: 0)
//        }
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
    var amountLabels = [UILabel]()
//    var amount: String {
//        get {
//            return amountLabels[selectedAmount].text!
//        }
//        set {
//            amountLabels[selectedAmount].text = amount
//        }
//    }
//    var currentAmountLabel: UILabel {
//        get {
//            return amountLabels[selectedAmount]
//        }
//        set {
//            amountLabels[selectedAmount] = currentAmountLabel
//            
//        }
//    }
    
//    func showCaseDidDismiss(showcase: MaterialShowcase, didTapTarget: Bool) {
//        if showcase.primaryText == NSLocalizedString("Ballon_ActiveerCollecte", comment: "") {
//            if !UserDefaults.standard.showCasesByUserID.contains(UserDefaults.Showcase.giveSituation.rawValue) {
//                showShowcase(message: NSLocalizedString("GiveSituationShowcaseTitle", comment: "") + " 😉", targetView: btnGive)
//                UserDefaults.standard.showCasesByUserID.append(UserDefaults.Showcase.giveSituation.rawValue)
//            }
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
//        showFirstBalloon()
        
//        if UserDefaults.standard.viewedCoachMarks >= 2 && !UserDefaults.standard.showCasesByUserID.contains(UserDefaults.Showcase.giveSituation.rawValue) {
//            showShowcase(message: NSLocalizedString("GiveSituationShowcaseTitle", comment: "GiveSituationShowcaseTitle"), targetView: btnGive)
//            UserDefaults.standard.showCasesByUserID.append(UserDefaults.Showcase.giveSituation.rawValue)
//        }
        
        
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
    
//    func addGestureRecognizerToView(view: UIView) {
//        let selectTap = UITapGestureRecognizer(target: self, action: #selector(tappedView))
//        selectTap.numberOfTapsRequired = 1
//        view.addGestureRecognizer(selectTap)
//
//        let tap = UITapGestureRecognizer(target: self, action:#selector(removeCollection))
//        tap.numberOfTapsRequired = 2
//        view.addGestureRecognizer(tap)
//
//        let longTap = UILongPressGestureRecognizer(target: self, action:#selector(clearAll))
//        longTap.minimumPressDuration = 1.0
//        view.addGestureRecognizer(longTap)
//    }
    
//    @objc func tappedView(_ sender: UITapGestureRecognizer) {
//        let tagIdx = sender.view?.tag
//        selectView(tagIdx!)
//    }
//
//
//    @IBOutlet weak var amountLabel: UILabel!
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
    
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

//    @IBAction func addCollection(_ sender: Any) {
//        print(UserDefaults.standard.viewedCoachMarks)
//        if UserDefaults.standard.viewedCoachMarks == 1 &&
//            !UserDefaults.standard.showCasesByUserID.contains(UserDefaults.Showcase.deleteMultipleCollects.rawValue) {
//            let alert = UIAlertController(title: NSLocalizedString("SecondCollection", comment: ""), message: NSLocalizedString("AddCollectConfirm", comment: ""), preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { action in
//                self.addCollect(sender)
//
//            }))
//            alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: { action in
//                return
//            }))
//            self.present(alert, animated: true, completion: nil)
//        } else {
//            addCollect(sender)
//        }
//
//
//    }
    
//    func addCollect(_ sender: Any)  {
//        let button = sender as! UIButton
//        NSLayoutConstraint.deactivate([self.widthConstraint])
//        self.widthConstraint = self.collectionView.widthAnchor.constraint(equalTo: self.containerCollection.widthAnchor, multiplier: 1)
//        self.widthConstraint.isActive = true
//        button.setImage(#imageLiteral(resourceName: "twocollect.png"), for: .normal)
//        if self.secondView.isHidden {
//            self.selectView(1)
//            numberOfCollects = 2
//        } else if self.thirdView.isHidden {
//            self.selectView(2)
//            numberOfCollects = 3
//        }
//    }
//
//    func selectView(_ idx: Int!) {
//        firstLine.isHidden = true
//        firstEuro.isHidden = true
//        secondLine.isHidden = true
//        secondEuro.isHidden = true
//        thirdLine.isHidden = true
//        thirdEuro.isHidden = true
//        pressedShortcutKey = true
//        switch idx {
//        case 0?:
//            self.lblTitle.title = numberOfCollects != 1 ? NSLocalizedString("ColId1", comment: "") : NSLocalizedString("Amount", comment: "")
//            firstLine.isHidden = false
//            firstEuro.isHidden = false
//
//        case 1?:
//            self.lblTitle.title = NSLocalizedString("ColId2", comment: "")
//            secondView.isHidden = false
//            secondLine.isHidden = false
//            secondEuro.isHidden = false
//
//            showSecondBalloon(view: secondView, arrowPointsTo: amountLabel2)
//        case 2?:
//            self.lblTitle.title = NSLocalizedString("ColId3", comment: "")
//            thirdView.isHidden = false
//            thirdLine.isHidden = false
//            thirdEuro.isHidden = false
//            leftSpacerView.isHidden = true
//            rightSpacerView.isHidden = true
//        default:
//            break
//        }
//        selectedAmount = idx
//    }
//
//    @objc func removeCollection() {
//        if !thirdView.isHidden {
//            amountLabel3.text = "0"
//            amountLabel3.textColor = UIColor.init(rgb: 0xD2D1D9)
//            thirdView.isHidden = true
//            leftSpacerView.isHidden = false
//            rightSpacerView.isHidden = false
//            if selectedAmount == 2 {
//                selectView(1)
//            }
//            numberOfCollects = 2
//        } else if !secondView.isHidden {
//            amountLabel2.text = "0"
//            amountLabel2.textColor = UIColor.init(rgb: 0xD2D1D9)
//            secondView.isHidden = true
//            collectionButton.setImage(#imageLiteral(resourceName: "onecollect.png"), for: .normal)
//
//            NSLayoutConstraint.deactivate([widthConstraint])
//            widthConstraint = collectionView.widthAnchor.constraint(equalToConstant: 150)
//            widthConstraint.isActive = true
//            numberOfCollects = 1
//            if selectedAmount <= 1 {
//                selectView(0)
//            }
//        }
//        checkAmounts()
//    }
//
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
//
//    func showFirstBalloon() {
//        if UserDefaults.standard.viewedCoachMarks != 0 || UserDefaults.standard.showCasesByUserID.contains(UserDefaults.Showcase.multipleCollects.rawValue) {
//            if !UserDefaults.standard.showCasesByUserID.contains(UserDefaults.Showcase.multipleCollects.rawValue) {
//                UserDefaults.standard.showCasesByUserID.append(UserDefaults.Showcase.multipleCollects.rawValue)
//            }
//            return
//        }
//
//        showShowcase(message: NSLocalizedString("Ballon_ActiveerCollecte", comment: ""), targetView: self.collectionButton)
//
//        UserDefaults.standard.viewedCoachMarks += 1
//        UserDefaults.standard.showCasesByUserID.append(UserDefaults.Showcase.multipleCollects.rawValue)
//    }
//
//    func showSecondBalloon(view: UIView, arrowPointsTo: UIView) {
//        if UserDefaults.standard.viewedCoachMarks != 1 || UserDefaults.standard.showCasesByUserID.contains(UserDefaults.Showcase.deleteMultipleCollects.rawValue){
//            if !UserDefaults.standard.showCasesByUserID.contains(UserDefaults.Showcase.deleteMultipleCollects.rawValue) {
//                UserDefaults.standard.showCasesByUserID.append(UserDefaults.Showcase.deleteMultipleCollects.rawValue)
//            }
//            return
//        }
//        showShowcase(message: NSLocalizedString("Ballon_VerwijderCollecte", comment: ""), targetView: self.amountLabel2)
//
//        UserDefaults.standard.viewedCoachMarks += 1
//        UserDefaults.standard.showCasesByUserID.append(UserDefaults.Showcase.deleteMultipleCollects.rawValue)
//    }
//
//    func reset() {
//        clearAmounts()
//        selectView(0)
//
//    }
//
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

class AmountUITextField: UIView {
    
    var borderView: UIView!
    var bar: UIView!
    var note: UILabel!
    var currency: UILabel!
    var amount: UILabel!
    var isCorrect = true
    var deleteBtn: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    @objc func click(sender: UIButton) {
        print("click")
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 2
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        self.backgroundColor = UIColor.clear
        
        borderView = UIView()
        borderView.isUserInteractionEnabled = false
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = UIColor.white
        borderView.frame = self.bounds
        borderView.layer.cornerRadius = 4
        borderView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        borderView.layer.borderWidth = 1
        borderView.layer.masksToBounds = true
        self.addSubview(borderView)
        borderView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        borderView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        borderView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        borderView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        bar = UIView()
        bar.isUserInteractionEnabled = false
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.heightAnchor.constraint(equalToConstant: 2).isActive = true
        bar.backgroundColor = #colorLiteral(red: 0.2549019608, green: 0.7882352941, blue: 0.5568627451, alpha: 1)
//        borderView.addSubview(bar)
//        bar.bottomAnchor.constraint(equalTo: borderView.bottomAnchor).isActive = true
//        bar.leadingAnchor.constraint(equalTo: borderView.leadingAnchor).isActive = true
//        bar.trailingAnchor.constraint(equalTo: borderView.trailingAnchor).isActive = true
        
        deleteBtn =  UIButton()
        deleteBtn.addTarget(self, action: #selector(click), for: UIControlEvents.touchUpInside)
        
        
        deleteBtn.setImage(#imageLiteral(resourceName: "decrease"), for: UIControlState.normal)
        deleteBtn.alpha = 0.5
        
        deleteBtn.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(deleteBtn)
        deleteBtn.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        deleteBtn.heightAnchor.constraint(equalToConstant: 20).isActive = true
        deleteBtn.contentMode = UIViewContentMode.scaleAspectFit
        deleteBtn.widthAnchor.constraint(equalToConstant: 20).isActive = true
        deleteBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        deleteBtn.isUserInteractionEnabled = true
        
        currency = UILabel()
        currency.translatesAutoresizingMaskIntoConstraints = false
        currency.isUserInteractionEnabled = false
        currency.font = UIFont(name: "Avenir-Heavy", size: 15)
        currency.textColor = #colorLiteral(red: 0.8235294118, green: 0.8196078431, blue: 0.8509803922, alpha: 1)
        currency.text = "€"
        self.addSubview(currency)
        currency.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30).isActive = true;
        currency.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        amount = UILabel()
        amount.translatesAutoresizingMaskIntoConstraints = false
        amount.isUserInteractionEnabled = false
        amount.font = UIFont(name: "Avenir-Light", size: 36)
        amount.textColor = #colorLiteral(red: 0.8235294118, green: 0.8196078431, blue: 0.8509803922, alpha: 1)
        amount.text = "1,00"
        self.addSubview(amount)
        amount.leadingAnchor.constraint(equalTo: currency.trailingAnchor, constant: 30).isActive = true;
        amount.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
//        note = UILabel()
//        note.translatesAutoresizingMaskIntoConstraints = false
//        note.isUserInteractionEnabled = false
//        note.font = UIFont(name: "Avenir-Light", size: 11)
//        note.text = "Tweede collecte"
//        note.textColor = #colorLiteral(red: 0.7372586131, green: 0.09625744075, blue: 0.1143460795, alpha: 1)
//        self.addSubview(note)
//        note.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25).isActive = true
//        note.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25).isActive = true
//        note.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
    }

    func focus(isCorrect: Bool, note: String) {
        self.isCorrect = isCorrect
        if isCorrect {
            bar.backgroundColor = #colorLiteral(red: 0.1098039216, green: 0.662745098, blue: 0.4235294118, alpha: 1)
            borderView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            self.note.alpha = 0
        } else {
            bar.backgroundColor = #colorLiteral(red: 0.7372586131, green: 0.09625744075, blue: 0.1143460795, alpha: 1)
            borderView.layer.borderColor = #colorLiteral(red: 0.7372586131, green: 0.09625744075, blue: 0.1143460795, alpha: 1)
            self.note.alpha = 1
            self.note.text = note
        }
    }
    
    func unfocus(isCorrect: Bool, note: String) {
        self.isCorrect = isCorrect
        if isCorrect {
            bar.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            borderView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            self.note.alpha = 0
        } else {
            self.note.text = note
            self.note.alpha = 1
            bar.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            borderView.layer.borderColor = #colorLiteral(red: 0.7372586131, green: 0.09625744075, blue: 0.1143460795, alpha: 1)
        }
    }
    
}
