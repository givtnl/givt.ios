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
    @IBOutlet var collectGroupNameLabel: UILabel? = UILabel()
    
    var viewModel: MonthlyOverviewCellViewModel? = nil {
        didSet{
            if let data = viewModel {
                collectGroupNameLabel!.text = data.collectGroupName
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    class func createCell() -> MonthlyOverviewCell? {
        let nib = UINib(nibName: "MonthlyOverviewCell", bundle: nil)
        let cell = nib.instantiate(withOwner: self, options: nil).last as? MonthlyOverviewCell
        return cell
    }
}
