//
//  TaxesViewController.swift
//  ios
//
//  Created by Lennie Stockman on 15/01/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit
import SVProgressHUD

class TaxesViewController: UIViewController, UIPickerViewDelegate {
    
    var currentYear: Int?
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return UserDefaults.standard.yearsWithGivts.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(UserDefaults.standard.yearsWithGivts[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentYear = UserDefaults.standard.yearsWithGivts[row]
        yearField.text = currentYear != nil ? String(currentYear!) : ""
    }
    @IBAction func showPicker(_ sender: Any) {
        yearField.becomeFirstResponder()
    }
    
    @IBOutlet var sendBtn: CustomButton!
    @IBOutlet var yearField: CustomUITextField!
    @IBOutlet var firstText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mutableAttributedString = NSMutableAttributedString()
        
        let boldAttribute = [
            NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17)!,
            NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
            ] as [NSAttributedStringKey : Any]
        
        let boldAttributedString = NSAttributedString(string: UserDefaults.standard.userExt!.email, attributes: boldAttribute)
        mutableAttributedString.append(NSAttributedString(string: NSLocalizedString("DownloadYearOverviewByChoice", comment: "") + " "))
        mutableAttributedString.append(boldAttributedString)
        firstText.attributedText = mutableAttributedString
        
        
        sendBtn.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
        
        let yearPicker = UIPickerView()
        yearPicker.delegate = self
        yearField.inputView = yearPicker
        yearField.text = UserDefaults.standard.yearsWithGivts.count >= 1 ? String(UserDefaults.standard.yearsWithGivts.first!) : ""
        createToolbar(yearField)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var goBack: UIBarButtonItem!
    
    @IBAction func send(_ sender: Any) {
    }
    @IBAction func sendOverview(_ sender: Any) {
        SVProgressHUD.show()
        GivtManager.shared.sendGivtOverview(year: Int(yearField.text!)!) { (status) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            if status {
                let alert = UIAlertController(title: NSLocalizedString("Success", comment: ""), message: NSLocalizedString("GiftsOverviewSent", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (uialertaction) in
                    self.navigationController?.popViewController(animated: true)
                }))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                
            } else {
                let alert = UIAlertController(title: NSLocalizedString("RequestFailed", comment: ""), message: NSLocalizedString("CouldNotSendTaxOverview", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                }))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func createToolbar(_ textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(TaxesViewController.hideKeyboard))
        
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        textField.inputAccessoryView = toolbar
    }
    
    func hideKeyboard(){
        self.view.endEditing(true)
    }
}
