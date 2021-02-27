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
    @IBOutlet weak var labelExternalGivtsTime: UILabel!
    @IBOutlet weak var labelExternalGivtsTimeDown: UILabel!
    @IBOutlet weak var labelExternalGivtsAmount: UILabel!
    @IBOutlet weak var buttonExternalGivtsAdd: CustomButton!
    @IBOutlet weak var buttonExternalGivtsSave: CustomButton!

    @IBOutlet weak var viewExternalGivtsTime: CustomButton!

    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    func setupUI() {
        labelExternalGivtsTimeDown.layer.addBorder(edge: .left, color: ColorHelper.UITextFieldBorderColor, thickness: 0.5)
        viewExternalGivtsTime.borderColor = ColorHelper.UITextFieldBorderColor
        viewExternalGivtsTime.borderWidth = 0.5
    }
}

private extension BudgetExternalGivtsViewController {
    private func createInfoText() -> NSMutableAttributedString {
        return NSMutableAttributedString()
            .bold("BudgetExternalGiftsInfoBold".localized + "\n", font: UIFont(name: "Avenir-Black", size: 16)!)
            .normal("BudgetExternalGiftsInfo".localized, font: UIFont(name: "Avenir-Light", size: 16)!)
    }
}
