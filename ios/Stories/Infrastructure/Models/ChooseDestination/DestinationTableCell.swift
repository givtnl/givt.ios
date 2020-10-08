//
//  DestinationViewModel.swift
//  ios
//
//  Created by Maarten Vergouwe on 16/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

internal final class DestinationTableCell : UITableViewCell {
    public var name: String = "" {
        didSet {
            collectGroupLabel.text = name
            collectGroupLabel.numberOfLines = 0
        }
    }
    
    public var iconRight: String = "" {
        didSet {
            iconLabelRight.text = iconRight
            iconLabelRight.isHidden = true
            if (iconRight != "") {
                iconLabelRight.isHidden = false
            }
        }
    }
    
    public var type: CollectGroupType = .church {
        didSet {
            switch type {
            case .church:
                iconLabel.text = "place-of-worship"
                break
            case .charity:
                iconLabel.text = "hands-helping"
                break
            case .campaign:
                iconLabel.text = "hand-holding-heart"
                break
            case .artist:
                iconLabel.text = "guitar"
                break
            case .none:
                iconLabel.text = ""
                break
            default:
                iconLabel.text = "place-of-worship"
                break
            }
        }
    }

    @IBOutlet var iconLabel: UILabel!
    @IBOutlet var collectGroupLabel: UILabel!
    @IBOutlet var iconLabelRight: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        iconLabelRight.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            toggleOn()
        } else {
            toggleOff()
        }
    }
    
    private func toggleOff() {
        setBackgroundColorRecursive(view: self.contentView, color: UIColor.clear)
        iconLabel.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        collectGroupLabel.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        iconLabelRight.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
    }
    
    private func toggleOn() {
        switch type {
        case .church:
            setBackgroundColorRecursive(view: self.contentView, color: #colorLiteral(red: 0.09952672571, green: 0.41830042, blue: 0.7092369199, alpha: 1))
            break
        case .charity:
            setBackgroundColorRecursive(view: self.contentView, color: #colorLiteral(red: 1, green: 0.6917269826, blue: 0, alpha: 1))
            break
        case .campaign:
            setBackgroundColorRecursive(view: self.contentView, color: #colorLiteral(red: 0.9460871816, green: 0.4409908056, blue: 0.3430213332, alpha: 1))
            break
        case .artist:
            setBackgroundColorRecursive(view: self.contentView, color: #colorLiteral(red: 0.2549019608, green: 0.7882352941, blue: 0.5568627451, alpha: 1))
            break            
        default:
            setBackgroundColorRecursive(view: self.contentView, color: #colorLiteral(red: 0.09952672571, green: 0.41830042, blue: 0.7092369199, alpha: 1))
            break
        }
        iconLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        collectGroupLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        iconLabelRight.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    private func setBackgroundColorRecursive(view: UIView, color: UIColor) {
        view.backgroundColor = color
        view.subviews.forEach {
            setBackgroundColorRecursive(view: $0, color: color)
        }
    }
}
