//
//  InfoViewRecurringRuleOverview.swift
//  ios
//
//  Created by Jonas Brabant on 16/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

protocol CloseInfoViewDelegate {
    func closeButtonTapped() -> Void
}

class InfoViewRecurringRuleOverview: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var closeButtonView: UIView!
    
    var delegate: CloseInfoViewDelegate? = nil

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
    }
    @IBAction func labelTapped(_ sender: UITapGestureRecognizer) {
        if let delegate = self.delegate {
            delegate.closeButtonTapped()
        }
    }
    
}
