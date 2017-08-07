//
//  AmViewController.swift
//  ios
//
//  Created by Lennie Stockman on 14/07/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class AmViewController: UIViewController {

    @IBOutlet weak var lblTitle: UINavigationItem!
    @IBOutlet weak var btnGive: CustomButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        btnGive.setTitle(NSLocalizedString("Give", comment: "Button to give"), for: UIControlState.normal)
        lblTitle.title = NSLocalizedString("Amount", comment: "Title on the AmountPage")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        super.navigationController?.navigationBar.barTintColor = UIColor(rgb: 0xF5F5F5)
    }

    @IBOutlet weak var amountLabel: UILabel!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addValue(sender:UIButton!) {
        if(amountLabel.text == "0"){
            amountLabel.text = ""
        }
        if((amountLabel.text?.contains(","))! && (sender.titleLabel?.text?.characters.contains(","))!){
            return
        }
        amountLabel.text = amountLabel.text! + sender.currentTitle!;
    
        
        print(amountLabel.text?.doubleValue)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
