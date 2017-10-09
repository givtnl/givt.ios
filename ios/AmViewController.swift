//
//  AmViewController.swift
//  ios
//
//  Created by Lennie Stockman on 14/07/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class AmViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var widthConstraint: NSLayoutConstraint!
    @IBOutlet var collectionView: UIView!
    
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
    private var amountLimit: Int {
        get {
            return UserDefaults.standard.amountLimit
        }
    }
    var selectedAmount = 0
    var amountList = ["0", "0", "0"]
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
        givtService = GivtService.sharedInstance
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
    
    func selectView(_ idx: Int!) {
        firstLine.isHidden = true
        secondLine.isHidden = true
        thirdLine.isHidden = true

        switch idx {
        case 1?:
            firstLine.isHidden = false
            selectedAmount = 0
        case 2?:
            secondLine.isHidden = false
            selectedAmount = 1
        case 3?:
            thirdLine.isHidden = false
            selectedAmount = 2
        default:
            //niets
            break
        }
    }
    
    @objc func removeCollection() {
        print("tapped")
        if !thirdView.isHidden {
            thirdView.isHidden = true
            leftSpacerView.isHidden = false
            rightSpacerView.isHidden = false
            if selectedAmount == 2 {
                selectView(2)
            }
        } else if !secondView.isHidden {
            secondView.isHidden = true
            collectionButton.setImage(#imageLiteral(resourceName: "onecollect.png"), for: .normal)
            if selectedAmount == 1 {
                selectView(1)
            }
            NSLayoutConstraint.deactivate([widthConstraint])
            widthConstraint = collectionView.widthAnchor.constraint(equalToConstant: 150)
            widthConstraint.isActive = true
        }
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

     @IBAction func actionGive(_ sender: Any) {
        let dAmount = Decimal(string: (amountLabel.text?.replacingOccurrences(of: ",", with: "."))!)
        if(dAmount! > Decimal(amountLimit)) {
            let alert = UIAlertController(
                title: NSLocalizedString("SomethingWentWrong2", comment: ""),
                message: NSLocalizedString("AmountLimitExceeded", comment: ""),
                preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("ChooseLowerAmount", comment: ""), style: .default, handler: {
                action in
                self.amountLabel.text = String(UserDefaults.standard.amountLimit)
                self.checkAmount()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("ChangeGivingLimit", comment: ""), style: .cancel, handler: { action in
                let amountLimitVC = self.storyboard?.instantiateViewController(withIdentifier: "alvc") as! AmountLimitViewController
                self.present(amountLimitVC, animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            if givtService.bluetoothEnabled {
                let scanVC = storyboard?.instantiateViewController(withIdentifier: "scanView") as! ScanViewController
                scanVC.amount = dAmount
                self.show(scanVC, sender: nil)
            } else {
                showBluetoothMessage()
            }
            
        }
        
     }
    
    func showBluetoothMessage() {
        let alert = UIAlertController(
            title: NSLocalizedString("SomethingWentWrong2", comment: ""),
            message: NSLocalizedString("BluetoothErrorMessage", comment: ""),
            preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("TurnOnBluetooth", comment: ""), style: .default, handler: { action in
            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { action in
            
        }))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func addCollection(_ sender: Any) {
        var button = sender as! UIButton
        NSLayoutConstraint.deactivate([widthConstraint])
        widthConstraint = collectionView.widthAnchor.constraint(equalTo: containerCollection.widthAnchor, multiplier: 1)
        widthConstraint.isActive = true
        button.setImage(#imageLiteral(resourceName: "twocollect.png"), for: .normal)
        if secondView.isHidden {
            secondView.isHidden = false
            selectView(2)
        } else if thirdView.isHidden {
            thirdView.isHidden = false
            leftSpacerView.isHidden = true
            rightSpacerView.isHidden = true
            selectView(3)
        }
    }
    
}
