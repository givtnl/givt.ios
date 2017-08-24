//
//  AmViewController.swift
//  ios
//
//  Created by Lennie Stockman on 14/07/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class AmViewController: UIViewController {

    private var pressedShortcutKey: Bool! = false
    private var decimalNotation: String! = "."
    @IBOutlet weak var lblTitle: UINavigationItem!
    @IBOutlet weak var btnGive: CustomButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        btnGive.setTitle(NSLocalizedString("Give", comment: "Button to give"), for: UIControlState.normal)
        lblTitle.title = NSLocalizedString("Amount", comment: "Title on the AmountPage")
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        super.viewWillAppear(true)
        super.navigationController?.navigationBar.barTintColor = UIColor(rgb: 0xF5F5F5)
        let backItem = UIBarButtonItem()
        backItem.title = NSLocalizedString("Cancel", comment: "Annuleer")
        backItem.style = .plain
        backItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir-Heavy", size: 20)!], for: .normal)
        self.navigationItem.backBarButtonItem = backItem
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
        
        
        if(amountLabel.text == "" && (sender.titleLabel?.text?.characters.contains(","))!){
            amountLabel.text = "0";
        }
        
        
        
        
        if let idx = amountLabel.text?.index(of: ",") {
            if(amountLabel.text?.substring(from: idx).characters.count == 3){
                return
            }
            if(sender.titleLabel?.text?.characters.contains(","))!{
                return
            }
            
            
        }
        
        if( amountLabel.text?.characters.count == 9){
            return
        }
        amountLabel.text = amountLabel.text! + sender.currentTitle!;
    
        
        
    }
    
    @IBAction func addShortcutValue(sender: UIButton!){
        clearAll(sender: sender)
        addValue(sender: sender)
        pressedShortcutKey = true
    }
    
    @IBAction func clearValue(sender: UIButton!){
        var amount: String = amountLabel.text!
        if(amount.characters.count == 0) {
            return
        }
        
        amount.remove(at: amount.index(before: amount.endIndex))
        amountLabel.text = amount
        if(amount.characters.count == 0){
            amountLabel.text = "0";
        }
    }

    @IBAction func clearAll(_ sender: Any) {
        amountLabel.text = "0";
    }

     @IBAction func actionGive(_ sender: Any) {
        let scanVC = storyboard?.instantiateViewController(withIdentifier: "scanView") as! ScanViewController
        scanVC.amount = Decimal(string: amountLabel.text!)
        self.show(scanVC, sender: nil)
     }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    

}
