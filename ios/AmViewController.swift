//
//  AmViewController.swift
//  ios
//
//  Created by Lennie Stockman on 14/07/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class AmViewController: UIViewController {

    private var amountLimit: Int = 0
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
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.amountLimit = 20
        amountLimit = UserDefaults.standard.amountLimit
        btnGive.setTitle(NSLocalizedString("Give", comment: "Button to give"), for: UIControlState.normal)
        lblTitle.title = NSLocalizedString("Amount", comment: "Title on the AmountPage")
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        super.viewWillAppear(true)
        
        decimalNotation = NSLocale.current.decimalSeparator! as String
        print(decimalNotation)
        
        super.navigationController?.navigationBar.barTintColor = UIColor(rgb: 0xF5F5F5)
        let backItem = UIBarButtonItem()
        backItem.title = NSLocalizedString("Cancel", comment: "Annuleer")
        backItem.style = .plain
        backItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir-Heavy", size: 20)!], for: .normal)
        btnGive.setBackgroundColor(color: UIColor.init(rgb: 0xE3E2E7), forState: .disabled)
        self.navigationItem.backBarButtonItem = backItem
        amountLabel.text = "0"
        checkAmount()
    }

    @IBOutlet weak var amountLabel: UILabel!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addValue(sender:UIButton!) {
        if(amountLabel.text == "0" || pressedShortcutKey){
            amountLabel.text = ""
        }
        if(pressedShortcutKey){ pressedShortcutKey = false }
        
        if(amountLabel.text! == "" && (sender.titleLabel?.text?.characters.contains(decimalNotation.characters.first!))!){
            amountLabel.text = "0";
        }
        
        if let idx = amountLabel.text?.index(of: decimalNotation) {
            if( ((amountLabel.text?.substring(from: idx).characters.count)! == 3)) || ((sender.titleLabel?.text?.characters.contains(decimalNotation.characters.first!))!){
                return
            }
        }
        
        if( amountLabel.text?.characters.count == 9){
            return
        }
        amountLabel.text = amountLabel.text! + sender.currentTitle!;
        checkAmount()
    }
    
    private func checkAmount(){
        let dAmount = Decimal(string: (amountLabel.text?.replacingOccurrences(of: ",", with: "."))!)!
        if(dAmount < 0.50 ) {
            btnGive.isEnabled = false
        } else {
            btnGive.isEnabled = true
        }
        
        amountLabel.textColor = dAmount > Decimal(amountLimit) ? UIColor.init(rgb: 0xd53d4c) : UIColor.init(rgb: 0xD2D1D9)
    }
    
    @IBAction func addShortcutValue(sender: UIButton!){
        clearAll(sender: sender)
        addValue(sender: sender)
        pressedShortcutKey = true
        checkAmount()
    }
    
    @IBAction func clearValue(sender: UIButton!){
        var amount: String = amountLabel.text!
        if(amount.characters.count == 0) {
            checkAmount()
            return
        }
        
        amount.remove(at: amount.index(before: amount.endIndex))
        amountLabel.text = amount
        if(amount.characters.count == 0){
            amountLabel.text = "0";
        }
        checkAmount()
        
    }

    @IBAction func clearAll(_ sender: Any) {
        amountLabel.text = "0";
        checkAmount()
    }

     @IBAction func actionGive(_ sender: Any) {
        let dAmount = Decimal(string: (amountLabel.text?.replacingOccurrences(of: ",", with: "."))!)
        if(dAmount! > Decimal(amountLimit)) {
            let alert = UIAlertController(
                title: NSLocalizedString("SomethingWentWrong2", comment: ""),
                message: NSLocalizedString("AmountLimitExceeded", comment: ""),
                preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("ChooseLowerAmount", comment: ""), style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: NSLocalizedString("ChangeGivingLimit", comment: ""), style: .cancel, handler: { action in
                //push geeflimiet pagina
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            let scanVC = storyboard?.instantiateViewController(withIdentifier: "scanView") as! ScanViewController
            scanVC.amount = dAmount
            self.show(scanVC, sender: nil)
        }
        
     }

    

}
