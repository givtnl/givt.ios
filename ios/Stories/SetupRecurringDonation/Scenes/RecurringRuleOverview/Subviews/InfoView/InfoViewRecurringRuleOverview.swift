//
//  InfoViewRecurringRuleOverview.swift
//  ios
//
//  Created by Jonas Brabant on 16/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class InfoViewRecurringRuleOverview: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var closeInfoView: UIView!
    @IBOutlet weak var closeInfoViewImage: UIImageView!
    
    @IBOutlet var infoViewTitle: UILabel!
    
    @IBOutlet var elementInProcessTitle: UILabel!
    @IBOutlet var elementProcessedTitle: UILabel!
    @IBOutlet var elementRefusedByBankTitle: UILabel!
    @IBOutlet var elementCancelledByUserTitle: UILabel!
    @IBOutlet var elementGiftAidedTitle: UILabel!
    
    @IBOutlet var elementInProcessStatus: UIView!
    @IBOutlet var elementProcessedStatus: UIView!
    @IBOutlet var elementRefusedByBankStatus: UIView!
    @IBOutlet var elementCancelledByUserStatus: UIView!
    @IBOutlet var elementGiftAidedStatus: UIImageView!
    
    @IBOutlet weak var elementStackView: UIStackView!
    @IBOutlet weak var giftAidView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let bundle = Bundle(for: InfoViewRecurringRuleOverview.self)
        bundle.loadNibNamed("InfoViewRecurringRuleOverview", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        infoViewTitle.text = "HistoryInfoTitle".localized
        elementInProcessTitle.text = "HistoryAmountAccepted".localized
        elementProcessedTitle.text = "HistoryAmountCollected".localized
        elementRefusedByBankTitle.text = "HistoryAmountDenied".localized
        elementCancelledByUserTitle.text = "HistoryAmountCancelled".localized
        elementGiftAidedTitle.text = "Gift Aided"
        
        elementInProcessStatus.backgroundColor = UIColor.init(rgb: 0x494874)
        elementInProcessStatus.layer.cornerRadius = 7.5
        elementProcessedStatus.backgroundColor = UIColor.init(rgb: 0x41c98e)
        elementProcessedStatus.layer.cornerRadius = 7.5
        elementRefusedByBankStatus.backgroundColor = UIColor.init(rgb: 0xd43d4c)
        elementRefusedByBankStatus.layer.cornerRadius = 7.5
        elementCancelledByUserStatus.backgroundColor = UIColor.init(rgb: 0xbcb9c9)
        elementCancelledByUserStatus.layer.cornerRadius = 7.5
        
        if UserDefaults.standard.accountType != AccountType.bacs {
            elementStackView.removeArrangedSubview(giftAidView)
            giftAidView.removeFromSuperview()
        }
        
    }
}
