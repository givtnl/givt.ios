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
    var closeInfoViewDelegate: CloseInfoViewDelegate? = nil
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    @IBAction func closeInfoView(_ sender: Any) {
        if let delegate = closeInfoViewDelegate {
            delegate.closeInfoView()
        }
    }
    private func commonInit() {
        let bundle = Bundle(for: InfoViewRecurringRuleOverview.self)
        bundle.loadNibNamed("InfoViewRecurringRuleOverview", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}

protocol CloseInfoViewDelegate {
    func closeInfoView()
}
