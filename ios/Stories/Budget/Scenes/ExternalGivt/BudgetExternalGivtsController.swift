//
//  ExternalGivtController.swift
//  ios
//
//  Created by Mike Pattyn on 27/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//
import UIKit
import Foundation
import SVProgressHUD

class BudgetExternalGivtsViewController : UIViewController {
    @IBOutlet weak var labelExternalGivtsInfo: UILabel!
    @IBOutlet weak var labelExternalGivtsSubtitle: UILabel!
    @IBOutlet weak var labelExternalGivtsOrganisation: UILabel!
    @IBOutlet weak var textFieldExternalGivtsOrganisation: TextFieldWithInset!
    @IBOutlet weak var labelExternalGivtsTime: UILabel!
    @IBOutlet weak var labelExternalGivtsTimeDown: UILabel!
    @IBOutlet weak var labelExternalGivtsAmount: UILabel!
    @IBOutlet weak var labelExternalGivtsAmountCurrency: UILabel!
    @IBOutlet weak var textFieldExternalGivtsAmount: UITextField!
    @IBOutlet weak var buttonExternalGivtsAdd: CustomButton!
    @IBOutlet weak var buttonExternalGivtsSave: CustomButton!

    @IBOutlet weak var viewExternalGivtsTime: CustomButton!
    @IBOutlet weak var viewExternalGivtsAmount: BudgetExternalGivtsViewWithBorder!
    
    @IBOutlet weak var bottomScrollViewConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: self.view.window)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        setupTerms()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        if !SVProgressHUD.isVisible() {
            SVProgressHUD.show()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    @IBAction func backButton(_ sender: Any) {
        try? Mediater.shared.send(request: GoBackOneControllerRoute(), withContext: self)
    }
    @IBAction func timeTapped(_ sender: Any) {
        print("Time tapped")
    }
    func createToolbar(_ textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(toolbarDoneButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        textField.inputAccessoryView = toolbar
    }
    @objc func toolbarDoneButtonTapped(_ sender: UIBarButtonItem){
        self.view.endEditing(true)
//        if let toolbar = startDateLabel.inputAccessoryView as? UIToolbar,
//           toolbar.items?.contains(where: { item in item == sender }) == true {
//            handleStartDatePicker(startDatePicker)
//        } else if let toolbar = endDateLabel.inputAccessoryView as? UIToolbar,
//           toolbar.items?.contains(where: { item in item == sender }) == true {
//            handleEndDatePicker(endDatePicker)
//        }
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        if #available(iOS 11.0, *) {
            bottomScrollViewConstraint.constant = keyboardFrame.size.height - view.safeAreaInsets.bottom - 64
        } else {
            bottomScrollViewConstraint.constant = keyboardFrame.size.height - 64
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        bottomScrollViewConstraint.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
}

extension BudgetExternalGivtsViewController {
    func setupTerms() {
        labelExternalGivtsInfo.attributedText = createInfoText()
        labelExternalGivtsInfo.textColor = .white
        labelExternalGivtsSubtitle.text = "BudgetExternalGiftsSubTitle".localized
        labelExternalGivtsOrganisation.text = "BudgetExternalGiftsOrg".localized
        labelExternalGivtsTime.text = "BudgetExternalGiftsTime".localized
        labelExternalGivtsAmount.text = "BudgetExternalGiftsAmount".localized
        buttonExternalGivtsAdd.setTitle("BudgetExternalGiftsAdd".localized, for: .normal)
        buttonExternalGivtsSave.setTitle("BudgetExternalGiftsSave".localized, for: .normal)
        
        createToolbar(textFieldExternalGivtsAmount)
        createToolbar(textFieldExternalGivtsOrganisation)

    }
    func setupUI() {
        labelExternalGivtsTimeDown.layer.addBorder(edge: .left, color: ColorHelper.UITextFieldBorderColor, thickness: 0.5)
        viewExternalGivtsTime.borderColor = ColorHelper.UITextFieldBorderColor
        viewExternalGivtsTime.borderWidth = 0.5
        
        labelExternalGivtsAmountCurrency.layer.addBorder(edge: .right, color: ColorHelper.UITextFieldBorderColor, thickness: 0.5)
        viewExternalGivtsAmount.borderColor = ColorHelper.UITextFieldBorderColor
        viewExternalGivtsAmount.borderWidth = 0.5
    }
}

private extension BudgetExternalGivtsViewController {
    private func createInfoText() -> NSMutableAttributedString {
        return NSMutableAttributedString()
            .bold("BudgetExternalGiftsInfoBold".localized + "\n", font: UIFont(name: "Avenir-Black", size: 16)!)
            .normal("BudgetExternalGiftsInfo".localized, font: UIFont(name: "Avenir-Light", size: 16)!)
    }
}
