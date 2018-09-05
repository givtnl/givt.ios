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
    @IBOutlet var containerCollection: UIView!
    @IBOutlet var amountLabel3: UILabel!
    @IBOutlet var amountLabel2: UILabel!
    @IBOutlet var leftSpacerView: UIView!
    @IBOutlet var rightSpacerView: UIView!
    @IBOutlet var firstView: UIView!
    @IBOutlet var firstLine: UIView!
    @IBOutlet var firstEuro: UILabel!
    @IBOutlet var secondLine: UIView!
    @IBOutlet var secondEuro: UILabel!
    @IBOutlet var thirdLine: UIView!
    @IBOutlet var thirdEuro: UILabel!
    @IBOutlet var secondView: UIView!
    @IBOutlet var thirdView: UIView!
    @IBOutlet var collectionButton: UIButton!
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
    var amount: String {
        get {
            return amountLabels[selectedAmount].text!
        }
        set {
            amountLabels[selectedAmount].text = amount
        }
    }
    var currentAmountLabel: UILabel {
        get {
            return amountLabels[selectedAmount]
        }
        set {
            amountLabels[selectedAmount] = currentAmountLabel
            
        }
    }
    
    func showCaseDidDismiss(showcase: MaterialShowcase, didTapTarget: Bool) {
        if showcase.primaryText == NSLocalizedString("Ballon_ActiveerCollecte", comment: "") {
            if !UserDefaults.standard.showCasesByUserID.contains(UserDefaults.Showcase.giveSituation.rawValue) {
                showShowcase(message: NSLocalizedString("GiveSituationShowcaseTitle", comment: "") + " 😉", targetView: btnGive)
                UserDefaults.standard.showCasesByUserID.append(UserDefaults.Showcase.giveSituation.rawValue)
            }
        }
    }
    
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
            firstQuickBtn.setTitle(fmt.string(from: UserDefaults.standard.amountPresets[0] as NSNumber), for: .normal)
            secondQuickBtn.setTitle(fmt.string(from: UserDefaults.standard.amountPresets[1] as NSNumber), for: .normal)
            thirdQuickBtn.setTitle(fmt.string(from: UserDefaults.standard.amountPresets[2] as NSNumber), for: .normal)
        }
    }
    @IBOutlet var firstQuickBtn: RoundedButton!
    @IBOutlet var secondQuickBtn: RoundedButton!
    @IBOutlet var thirdQuickBtn: RoundedButton!
    @IBOutlet var btnComma: UIButton!
    @IBOutlet weak var lblTitle: UINavigationItem!
    @IBOutlet weak var btnGive: CustomButton!
    
    private var givtService:GivtManager!
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        givtService = GivtManager.shared
        btnGive.setTitle(NSLocalizedString("Next", comment: "Button to give"), for: UIControlState.normal)
        btnGive.accessibilityLabel = NSLocalizedString("Next", comment: "Button to give")
        lblTitle.title = NSLocalizedString("Amount", comment: "Title on the AmountPage")
        
        amountLabels = [amountLabel, amountLabel2, amountLabel3]
        menu.accessibilityLabel = "Menu"
        addGestureRecognizerToView(view: firstView)
        addGestureRecognizerToView(view: secondView)
        addGestureRecognizerToView(view: thirdView)
        
        secondView.isHidden = true
        secondLine.isHidden = true
        thirdView.isHidden = true
        thirdLine.isHidden = true
        
        
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
        btnGive.setBackgroundColor(color: UIColor.init(rgb: 0xE3E2E7), forState: .disabled)
        self.navigationItem.backBarButtonItem = backItem
        checkAmounts()
        
        log.info(message:"Mandate signed: " + String(UserDefaults.standard.mandateSigned))
        menu.image = LoginManager.shared.isFullyRegistered ? #imageLiteral(resourceName: "menu_base") : #imageLiteral(resourceName: "menu_badge")
        
        if self.presentedViewController?.restorationIdentifier == "FAQViewController" {
            self._cameFromFAQ = true
        }
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.init(rgb: 0x2E2957), NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 18)!]
    }
    
    private var _cameFromFAQ: Bool = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigiationManager.delegate = self
        showFirstBalloon()
        
        if UserDefaults.standard.viewedCoachMarks >= 2 && !UserDefaults.standard.showCasesByUserID.contains(UserDefaults.Showcase.giveSituation.rawValue) {
            showShowcase(message: NSLocalizedString("GiveSituationShowcaseTitle", comment: "GiveSituationShowcaseTitle"), targetView: btnGive)
            UserDefaults.standard.showCasesByUserID.append(UserDefaults.Showcase.giveSituation.rawValue)
        }
        
        
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
    
    func addGestureRecognizerToView(view: UIView) {
        let selectTap = UITapGestureRecognizer(target: self, action: #selector(tappedView))
        selectTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(selectTap)
        
        let tap = UITapGestureRecognizer(target: self, action:#selector(removeCollection))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        
        let longTap = UILongPressGestureRecognizer(target: self, action:#selector(clearAll))
        longTap.minimumPressDuration = 1.0
        view.addGestureRecognizer(longTap)
    }
    
    @objc func tappedView(_ sender: UITapGestureRecognizer) {
        let tagIdx = sender.view?.tag
        selectView(tagIdx!)
    }


    @IBOutlet weak var amountLabel: UILabel!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addValue(sender:UIButton!) {
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
    
    @IBAction func addShortcutValue(sender: UIButton!){
        currentAmountLabel.text = sender.currentTitle
        if sender.currentTitle!.contains(",") {
            let decimal = Decimal(string: sender.currentTitle!.replacingOccurrences(of: ",", with: "."))
            if decimal != 2.5 && decimal != 7.5 && decimal != 12.5 {
                self.log.info(message: "User used a custom amount preset")
            }
        } else if let decimal = Decimal(string: sender.currentTitle!) {
            if decimal != 2.5 && decimal != 7.5 && decimal != 12.5 {
                self.log.info(message: "User used a custom amount preset")
            }
        }
        checkAmounts()
        pressedShortcutKey = true
    }
    
    @IBAction func clearValue(sender: UIButton!){
        var amount: String = self.currentAmountLabel.text!
        if amount.count == 0 {
            checkAmounts()
            return
        }
        
        amount.remove(at: amount.index(before: amount.endIndex))
        self.currentAmountLabel.text! = amount
        if amount.count == 0 || pressedShortcutKey {
            self.currentAmountLabel.text = "0";
        }
        checkAmounts()
        
    }

    @IBAction func clearAll(_ sender: Any) {
        self.currentAmountLabel.text = "0";
        checkAmounts()
    }
    
    func clearAmounts() {
        let emptyString = "0"
        self.amountLabel.text? = emptyString
        self.amountLabel2.text? = emptyString
        self.amountLabel3.text? = emptyString
        removeCollection()
        removeCollection()
        checkAmounts()
    }

    fileprivate func showAmountTooLow() {
        let alert = UIAlertController(title: "", message: NSLocalizedString("GivtNotEnough", comment: "").replacingOccurrences(of: "{0}", with: NSLocalizedString("GivtMinimumAmountEuro", comment: "").replacingOccurrences(of: ".", with: decimalNotation)), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in  }))
        self.present(alert, animated: true, completion: {})
    }
    
    @IBAction func actionGive(_ sender: Any) {
        var numberOfZeroAmounts = 0
        for index in 0..<numberOfCollects {
            let parsedDecimal = Decimal(string: (amountLabels[index].text!.replacingOccurrences(of: ",", with: ".")))!
            
            if parsedDecimal > Decimal(UserDefaults.standard.amountLimit) {
                selectView(index)
                displayAmountLimitExceeded()
                return
            }
            
            if parsedDecimal  > 0 && parsedDecimal < 0.50 {
                selectView(index)
                showAmountTooLow()
                return
            }
            
            if parsedDecimal == 0 {
                numberOfZeroAmounts += 1
            }
            
            if numberOfZeroAmounts == numberOfCollects {
                showAmountTooLow()
                return
            }
        }
        

        givtService.setAmounts(amounts: [(amountLabels[0].text?.decimalValue)!, (amountLabels[1].text?.decimalValue)!, (amountLabels[2].text?.decimalValue)!])
        
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
    
    func displayAmountLimitExceeded() {
        let alert = UIAlertController(
            title: NSLocalizedString("SomethingWentWrong2", comment: ""),
            message: NSLocalizedString("AmountLimitExceeded", comment: ""),
            preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ChooseLowerAmount", comment: ""), style: .default, handler: {
            action in
            self.currentAmountLabel.text = String(UserDefaults.standard.amountLimit)
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

    @IBAction func addCollection(_ sender: Any) {
        print(UserDefaults.standard.viewedCoachMarks)
        if UserDefaults.standard.viewedCoachMarks == 1 &&
            !UserDefaults.standard.showCasesByUserID.contains(UserDefaults.Showcase.deleteMultipleCollects.rawValue) {
            let alert = UIAlertController(title: NSLocalizedString("MultipleCollections", comment: ""), message: NSLocalizedString("AddCollectConfirm", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { action in
                self.addCollect(sender)
                
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: { action in
                return
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            addCollect(sender)
        }
        

    }
    
    func addCollect(_ sender: Any)  {
        let button = sender as! UIButton
        NSLayoutConstraint.deactivate([self.widthConstraint])
        self.widthConstraint = self.collectionView.widthAnchor.constraint(equalTo: self.containerCollection.widthAnchor, multiplier: 1)
        self.widthConstraint.isActive = true
        button.setImage(#imageLiteral(resourceName: "twocollect.png"), for: .normal)
        if self.secondView.isHidden {
            self.selectView(1)
            numberOfCollects = 2
        } else if self.thirdView.isHidden {
            self.selectView(2)
            numberOfCollects = 3
        }
    }
    
    func selectView(_ idx: Int!) {
        firstLine.isHidden = true
        firstEuro.isHidden = true
        secondLine.isHidden = true
        secondEuro.isHidden = true
        thirdLine.isHidden = true
        thirdEuro.isHidden = true
        pressedShortcutKey = true
        switch idx {
        case 0?:
            self.lblTitle.title = numberOfCollects != 1 ? NSLocalizedString("ColId1", comment: "") : NSLocalizedString("Amount", comment: "")
            firstLine.isHidden = false
            firstEuro.isHidden = false
            
        case 1?:
            self.lblTitle.title = NSLocalizedString("ColId2", comment: "")
            secondView.isHidden = false
            secondLine.isHidden = false
            secondEuro.isHidden = false
            
            showSecondBalloon(view: secondView, arrowPointsTo: amountLabel2)
        case 2?:
            self.lblTitle.title = NSLocalizedString("ColId3", comment: "")
            thirdView.isHidden = false
            thirdLine.isHidden = false
            thirdEuro.isHidden = false
            leftSpacerView.isHidden = true
            rightSpacerView.isHidden = true
        default:
            break
        }
        selectedAmount = idx
    }
    
    @objc func removeCollection() {
        if !thirdView.isHidden {
            amountLabel3.text = "0"
            amountLabel3.textColor = UIColor.init(rgb: 0xD2D1D9)
            thirdView.isHidden = true
            leftSpacerView.isHidden = false
            rightSpacerView.isHidden = false
            if selectedAmount == 2 {
                selectView(1)
            }
            numberOfCollects = 2
        } else if !secondView.isHidden {
            amountLabel2.text = "0"
            amountLabel2.textColor = UIColor.init(rgb: 0xD2D1D9)
            secondView.isHidden = true
            collectionButton.setImage(#imageLiteral(resourceName: "onecollect.png"), for: .normal)
           
            NSLayoutConstraint.deactivate([widthConstraint])
            widthConstraint = collectionView.widthAnchor.constraint(equalToConstant: 150)
            widthConstraint.isActive = true
            numberOfCollects = 1
            if selectedAmount <= 1 {
                selectView(0)
            }
        }
        checkAmounts()
    }
    
    func checkAmounts() {
        var amountsUnder50C = 0
        for index in 0..<numberOfCollects {
            let parsedDecimal = Decimal(string: (amountLabels[index].text!.replacingOccurrences(of: ",", with: ".")))!
            if parsedDecimal < 0.50 {
                amountsUnder50C += 1
            }
            btnGive.isEnabled = amountsUnder50C != numberOfCollects
        }
        
        currentAmountLabel.textColor = Decimal(string: (currentAmountLabel.text!.replacingOccurrences(of: ",", with: ".")))! > Decimal(amountLimit) ? UIColor.init(rgb: 0xb91a24).withAlphaComponent(0.5) : UIColor.init(rgb: 0xD2D1D9)
    }
    
    func showShowcase(message: String, targetView: UIView) {
        let showCase = MaterialShowcase()
        showCase.delegate = self
        showCase.primaryText = message
        showCase.secondaryText = NSLocalizedString("CancelFeatureMessage", comment: "")
        
        DispatchQueue.main.async {
            showCase.setTargetView(view: targetView) // always required to set targetView
            showCase.shouldSetTintColor = false
            showCase.backgroundPromptColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
            showCase.show(completion: nil)
        }
    }
    
    func showFirstBalloon() {
        if UserDefaults.standard.viewedCoachMarks != 0 || UserDefaults.standard.showCasesByUserID.contains(UserDefaults.Showcase.multipleCollects.rawValue) {
            if !UserDefaults.standard.showCasesByUserID.contains(UserDefaults.Showcase.multipleCollects.rawValue) {
                UserDefaults.standard.showCasesByUserID.append(UserDefaults.Showcase.multipleCollects.rawValue)
            }
            return
        }
        
        showShowcase(message: NSLocalizedString("Ballon_ActiveerCollecte", comment: ""), targetView: self.collectionButton)
        
        UserDefaults.standard.viewedCoachMarks += 1
        UserDefaults.standard.showCasesByUserID.append(UserDefaults.Showcase.multipleCollects.rawValue)
    }

    func showSecondBalloon(view: UIView, arrowPointsTo: UIView) {
        if UserDefaults.standard.viewedCoachMarks != 1 || UserDefaults.standard.showCasesByUserID.contains(UserDefaults.Showcase.deleteMultipleCollects.rawValue){
            if !UserDefaults.standard.showCasesByUserID.contains(UserDefaults.Showcase.deleteMultipleCollects.rawValue) {
                UserDefaults.standard.showCasesByUserID.append(UserDefaults.Showcase.deleteMultipleCollects.rawValue)
            }
            return
        }
        showShowcase(message: NSLocalizedString("Ballon_VerwijderCollecte", comment: ""), targetView: self.amountLabel2)
        
        UserDefaults.standard.viewedCoachMarks += 1
        UserDefaults.standard.showCasesByUserID.append(UserDefaults.Showcase.deleteMultipleCollects.rawValue)
    }

    func reset() {
        clearAmounts()
        selectView(0)
       
    }

    let slideAnimator = CustomPresentModalAnimation()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "faq" {
            let destination = segue.destination
            destination.transitioningDelegate = slideAnimator
        }
    }
    
    @IBAction func returnFromSegue(sender: UIStoryboardSegue) {
        
    }
}
