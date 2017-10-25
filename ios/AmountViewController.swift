//
//  AmViewController.swift
//  ios
//
//  Created by Lennie Stockman on 14/07/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class AmountViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var widthConstraint: NSLayoutConstraint!
    @IBOutlet var collectionView: UIView!
    
    @IBOutlet var menu: UIBarButtonItem!
    @IBOutlet var containerCollection: UIView!
    @IBOutlet var amountLabel3: UILabel!
    @IBOutlet var amountLabel2: UILabel!
    @IBOutlet var leftSpacerView: UIView!
    @IBOutlet var rightSpacerView: UIView!
    @IBOutlet var firstView: UIView!
    @IBOutlet var firstLine: UIView!
    @IBOutlet var secondLine: UIView!
    @IBOutlet var thirdLine: UIView!
    @IBOutlet var secondView: UIView!
    @IBOutlet var thirdView: UIView!
    @IBOutlet var collectionButton: UIButton!
    var firstBalloon: Balloon?
    var secondBalloon: Balloon?
    var thirdBalloon: Balloon?
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
    
    
    
    private var pressedShortcutKey: Bool! = false
    private var decimalNotation: String! = "," {
        didSet {
            btnComma.setTitle(decimalNotation, for: .normal)
            let fmt = NumberFormatter()
            fmt.minimumFractionDigits = 2
            let test: String = fmt.string(from: 7.50)!
            btnSevenEuro.setTitle(test, for: .normal)
        }
    }
    @IBOutlet var btnSevenEuro: RoundedButton!
    @IBOutlet var btnComma: UIButton!
    @IBOutlet weak var lblTitle: UINavigationItem!
    @IBOutlet weak var btnGive: CustomButton!
    
    private var givtService:GivtService!
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        givtService = GivtService.shared
        btnGive.setTitle(NSLocalizedString("Give", comment: "Button to give"), for: UIControlState.normal)
        lblTitle.title = NSLocalizedString("Amount", comment: "Title on the AmountPage")
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        amountLabels = [amountLabel, amountLabel2, amountLabel3]
        
        addGestureRecognizerToView(view: firstView)
        addGestureRecognizerToView(view: secondView)
        addGestureRecognizerToView(view: thirdView)
        
        secondView.isHidden = true
        secondLine.isHidden = true
        thirdView.isHidden = true
        thirdLine.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        super.viewWillAppear(true)
        decimalNotation = NSLocale.current.decimalSeparator! as String
        super.navigationController?.navigationBar.barTintColor = UIColor(rgb: 0xF5F5F5)
        let backItem = UIBarButtonItem()
        backItem.title = NSLocalizedString("Cancel", comment: "Annuleer")
        backItem.style = .plain
        backItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir-Heavy", size: 20)!], for: .normal)
        btnGive.setBackgroundColor(color: UIColor.init(rgb: 0xE3E2E7), forState: .disabled)
        self.navigationItem.backBarButtonItem = backItem
        checkAmount()
        
        print("Mandate signed: ", UserDefaults.standard.mandateSigned)
        
        menu.image = LoginManager.shared.isFullyRegistered ? #imageLiteral(resourceName: "menu_base") : #imageLiteral(resourceName: "menu_badge")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showFirstBalloon()
        if !LoginManager.shared.isFullyRegistered && LoginManager.shared.userClaim != .giveOnce {
            
            let alert = UIAlertController(title: NSLocalizedString("ImportantReminder", comment: ""), message: NSLocalizedString("FinalizeRegistrationPopupText", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("AskMeLater", comment: ""), style: UIAlertActionStyle.default, handler: { action in  }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("FinalizeRegistration", comment: ""), style: .cancel, handler: { (action) in
                //push registration flow
            }))
            self.present(alert, animated: true, completion: {})
        }
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
    
    func tappedView(_ sender: UITapGestureRecognizer) {
        var tagIdx = sender.view?.tag
        selectView(tagIdx!)
    }


    @IBOutlet weak var amountLabel: UILabel!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addValue(sender:UIButton!) {
        hideBalloons()
        if currentAmountLabel.text == "0" || pressedShortcutKey {
            currentAmountLabel.text = ""
        }
        
        if currentAmountLabel.text! == "" && (sender.titleLabel?.text?.characters.contains(decimalNotation.characters.first!))! {
            currentAmountLabel.text = "0";
        }
        
        if let idx = currentAmountLabel.text?.index(of: decimalNotation) {
            if( ((currentAmountLabel.text?.substring(from: idx).characters.count)! == 3)) || ((sender.titleLabel?.text?.characters.contains(decimalNotation.characters.first!))!){
                return
            }
        }

        if (currentAmountLabel.text?.characters.contains(decimalNotation.characters.first!))! {
            if currentAmountLabel.text?.characters.count == 9 {
                return
            }
        } else if currentAmountLabel.text?.characters.count == 6 {
            return
        }
        currentAmountLabel.text = currentAmountLabel.text! + sender.currentTitle!;
        checkAmount()
        pressedShortcutKey = false
    }
    
    private func checkAmount(){
        let dAmount = Decimal(string: (currentAmountLabel.text?.replacingOccurrences(of: ",", with: "."))!)!
        if dAmount < 0.50 {
            btnGive.isEnabled = false
        } else {
            btnGive.isEnabled = true
        }
        
        currentAmountLabel.textColor = dAmount > Decimal(amountLimit) ? UIColor.init(rgb: 0xb91a24).withAlphaComponent(0.5) : UIColor.init(rgb: 0xD2D1D9)
        
        
    }
    
    @IBAction func addShortcutValue(sender: UIButton!){
        currentAmountLabel.text = sender.currentTitle
        checkAmount()
        pressedShortcutKey = true
    }
    
    @IBAction func clearValue(sender: UIButton!){
        var amount: String = self.currentAmountLabel.text!
        if amount.characters.count == 0 {
            checkAmount()
            return
        }
        
        amount.remove(at: amount.index(before: amount.endIndex))
        self.currentAmountLabel.text! = amount
        if amount.characters.count == 0 || pressedShortcutKey {
            self.currentAmountLabel.text = "0";
        }
        checkAmount()
        
    }

    @IBAction func clearAll(_ sender: Any) {
        self.currentAmountLabel.text = "0";
        checkAmount()
    }
    
    func clearAmounts() {
        let emptyString = "0"
        self.amountLabel.text? = emptyString
        self.amountLabel2.text? = emptyString
        self.amountLabel3.text? = emptyString
        removeCollection()
        removeCollection()
        checkAmount()
    }

     @IBAction func actionGive(_ sender: Any) {
        for index in 0..<numberOfCollects {
            print(amountLabels[index].text)
            let parsedDecimal = Decimal(string: (amountLabels[index].text!.replacingOccurrences(of: ",", with: ".")))!
            
            if parsedDecimal > Decimal(UserDefaults.standard.amountLimit) {
                selectView(index)
                displayAmountLimitExceeded()
                return
            }
            
            if parsedDecimal  > 0 && parsedDecimal < 0.50 {
                selectView(index)
                let alert = UIAlertController(title: "", message: NSLocalizedString("GivtNotEnough", comment: "").replacingOccurrences(of: "{0}", with: NSLocalizedString("GivtMinimumAmountEuro", comment: "").replacingOccurrences(of: ".", with: decimalNotation)), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in  }))
                self.present(alert, animated: true, completion: {})
                return
            }
        }
        
    
        if givtService.bluetoothEnabled {
            let scanVC = storyboard?.instantiateViewController(withIdentifier: "scanView") as! ScanViewController
            givtService.setAmounts(amounts: [(amountLabels[0].text?.decimalValue)!, (amountLabels[1].text?.decimalValue)!, (amountLabels[2].text?.decimalValue)!])
            clearAmounts()
            self.show(scanVC, sender: nil)
        } else {
            showBluetoothMessage()
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
            self.checkAmount()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("ChangeGivingLimit", comment: ""), style: .cancel, handler: { action in
            let amountLimitVC = self.storyboard?.instantiateViewController(withIdentifier: "alvc") as! AmountLimitViewController
            self.present(amountLimitVC, animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showBluetoothMessage() {
        let alert = UIAlertController(
            title: NSLocalizedString("SomethingWentWrong2", comment: ""),
            message: NSLocalizedString("BluetoothErrorMessage", comment: ""),
            preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("TurnOnBluetooth", comment: ""), style: .default, handler: { action in
            //UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
            let url = URL(string: "App-Prefs:root=Bluetooth") //for bluetooth setting
            let app = UIApplication.shared
            app.openURL(url!)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { action in
            
        }))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func addCollection(_ sender: Any) {
        print(UserDefaults.standard.viewedCoachMarks)
        if UserDefaults.standard.viewedCoachMarks == 1 {
            let alert = UIAlertController(title: NSLocalizedString("MultipleCollections", comment: ""), message: NSLocalizedString("AddCollectConfirm", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { action in
                
                self.addCollect(sender)
                
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: { action in
                self.firstBalloon?.hide(true)
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
        } else if self.thirdView.isHidden {
            self.selectView(2)
        }
    }
    
    func selectView(_ idx: Int!) {
        firstLine.isHidden = true
        secondLine.isHidden = true
        thirdLine.isHidden = true
        
        switch idx {
        case 0?:
            firstLine.isHidden = false
        case 1?:
            secondView.isHidden = false
            secondLine.isHidden = false
            
            showSecondBalloon(view: secondView, arrowPointsTo: amountLabel2)
        case 2?:
            thirdView.isHidden = false
            thirdLine.isHidden = false
            leftSpacerView.isHidden = true
            rightSpacerView.isHidden = true

            showThirdBalloon(view: thirdView, arrowPointsTo: amountLabel3)
        default:
            break
        }
        selectedAmount = idx
        numberOfCollects = idx + 1
    }
    
    @objc func removeCollection() {
        print("tapped")
        if !thirdView.isHidden {
            thirdView.isHidden = true
            leftSpacerView.isHidden = false
            rightSpacerView.isHidden = false
            if selectedAmount == 2 {
                selectView(1)
            }
            numberOfCollects = 2
            thirdBalloon?.hide()
        } else if !secondView.isHidden {
            secondView.isHidden = true
            collectionButton.setImage(#imageLiteral(resourceName: "onecollect.png"), for: .normal)
            if selectedAmount == 1 {
                selectView(0)
            }
            NSLayoutConstraint.deactivate([widthConstraint])
            widthConstraint = collectionView.widthAnchor.constraint(equalToConstant: 150)
            widthConstraint.isActive = true
            numberOfCollects = 1
            secondBalloon?.hide()
        }
    }
    
    func showFirstBalloon() {
        firstBalloon?.hide()
        if UserDefaults.standard.viewedCoachMarks != 0 {
            return
        }
        
        let balloon = Balloon(text: NSLocalizedString("Ballon_ActiveerCollecte", comment: ""))
        self.view.addSubview(balloon)
        
        balloon.positionTooltip()
        balloon.pinRight(view: self.collectionButton)
        balloon.pinTop(view: self.containerCollection, 0)
        self.view.layoutIfNeeded()
        balloon.bounce()
        
        self.firstBalloon = balloon
        UserDefaults.standard.viewedCoachMarks += 1
    }

    func showSecondBalloon(view: UIView, arrowPointsTo: UIView) {
        firstBalloon?.hide()
        if UserDefaults.standard.viewedCoachMarks != 1 {
            return
        }
        
        let balloon = Balloon(text: NSLocalizedString("Ballon_VerwijderCollecte", comment: ""))
        self.view.addSubview(balloon)
        self.view.layoutIfNeeded()
        
        balloon.centerTooltip(view: arrowPointsTo)
        
        balloon.pinTop(view: self.containerCollection)
        balloon.pinLeft(view: view, -((200 - secondView.bounds.width)/2))
        self.view.layoutIfNeeded()
        balloon.bounce()
        self.secondBalloon = balloon
        UserDefaults.standard.viewedCoachMarks += 1
    }

    
    func showThirdBalloon(view: UIView, arrowPointsTo: UIView) {
        secondBalloon?.hide()
        if UserDefaults.standard.viewedCoachMarks != 2 {
            return
        }
        
        let balloon = Balloon(text: NSLocalizedString("Ballon_VerwijderCollecte", comment: ""))
        self.view.addSubview(balloon)
        self.view.layoutIfNeeded()
        
        balloon.centerTooltip(view: arrowPointsTo)
        
        balloon.pinTop(view: self.containerCollection)
        balloon.pinRight(view: self.containerCollection, 5)
        self.view.layoutIfNeeded()
        balloon.bounce()
        self.thirdBalloon = balloon
        UserDefaults.standard.viewedCoachMarks += 1
    }
    
    func hideBalloons() {
        firstBalloon?.hide()
        secondBalloon?.hide()
        thirdBalloon?.hide()
    }
    
}
