//
//  MonthlyOverviewCell.swift
//  ios
//
//  Created by Mike Pattyn on 17/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import UIKit
import Foundation

internal final class MonthlyOverviewCell : UITableViewCell {
    var viewModel: MonthlyOverviewCellViewModel? = nil {
        didSet{
            if let data = viewModel {
                
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
