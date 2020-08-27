//
//  RecurringRuleTableCell.swift
//  ios
//
//  Created by Jonas Brabant on 27/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import Foundation

internal final class RecurringRuleTableCell : UITableViewCell {
    @IBOutlet weak var Name: UILabel!
    
    //    public var name: String = "" {
//        didSet {
//            collectGroupLabel.text = name
//            collectGroupLabel.numberOfLines = 0
//        }
//    }
//    
//    public var type: CollectGroupType = .church {
//        didSet {
//            switch type {
//                case .church:
//                    iconLabel.text = "place-of-worship"
//                    break
//                case .charity:
//                    iconLabel.text = "hands-helping"
//                    break
//                case .campaign:
//                    iconLabel.text = "hand-holding-heart"
//                    break
//                case .artist:
//                    iconLabel.text = "guitar"
//                    break
//                default:
//                    iconLabel.text = "place-of-worship"
//                    break
//                }
//        }
//    }
//
//    @IBOutlet var iconLabel: UILabel!
//    @IBOutlet var collectGroupLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}
