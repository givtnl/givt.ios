//
//  YearViewBodyLine.swift
//  ios
//
//  Created by Mike Pattyn on 07/05/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class YearViewBodyLine: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var givingGoalView: UIView!
    @IBOutlet weak var givingGoalLabel: UILabel!
    @IBOutlet weak var givingGoalWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var givenView: UIView!
    @IBOutlet weak var givenLabel: UILabel!
    @IBOutlet weak var givenViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var alternateLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.topRight, .bottomRight], radius: 7)
    }
    private func commonInit() {
        let bundle = Bundle(for: YearViewBodyLine.self)
        bundle.loadNibNamed("YearViewBodyLine", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func hideGivingGoal() {
        givingGoalView.isHidden = true
        givingGoalLabel.isHidden = true
    }
    
    func showGivingGoal() {
        givingGoalView.isHidden = false
        givingGoalLabel.isHidden = false
    }
}
