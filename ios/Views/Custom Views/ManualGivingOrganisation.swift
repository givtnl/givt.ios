//
//  ManualGivingOrganisation.swift
//  ios
//
//  Created by Lennie Stockman on 12/01/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit

class ManualGivingOrganisation: UITableViewCell {
    public var nameSpace: String = "" {
        didSet {
            let type  = nameSpace.substring(16..<19)
            if type.matches("c[0-9]|d[be]") { //is a chrch
                iconLabel.text = "place-of-worship"
            } else if type.matches("d[0-9]") { //stichitng
                iconLabel.text = "hands-helping"
            } else if type.matches("a[0-9]") { //acties
                iconLabel.text = "hand-holding-heart"
            } else if type.matches("b[0-9]") {
                iconLabel.text = "guitar"
            }
        }
    }
    
    @IBOutlet var iconLabel: UILabel!
    @IBOutlet var organisationLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func toggleOff() {
        setBackgroundColorRecursive(view: self, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        iconLabel.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        organisationLabel.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
    }
    
    func toggleOn() {
        let type  = nameSpace.substring(16..<19)
        if type.matches("c[0-9]|d[be]") { //is a chrch
            setBackgroundColorRecursive(view: self, color: #colorLiteral(red: 0.09952672571, green: 0.41830042, blue: 0.7092369199, alpha: 1))
        } else if type.matches("d[0-9]") { //stichitng
            setBackgroundColorRecursive(view: self, color: #colorLiteral(red: 1, green: 0.6917269826, blue: 0, alpha: 1))
        } else if type.matches("a[0-9]") { //acties
            setBackgroundColorRecursive(view: self, color: #colorLiteral(red: 0.9460871816, green: 0.4409908056, blue: 0.3430213332, alpha: 1))
        } else if type.matches("b[0-9]") {
            setBackgroundColorRecursive(view: self, color: #colorLiteral(red: 0.2549019608, green: 0.7882352941, blue: 0.5568627451, alpha: 1))
        }
        iconLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        organisationLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    private func setBackgroundColorRecursive(view: UIView, color: UIColor) {
        view.subviews.forEach {
            $0.backgroundColor = color
            setBackgroundColorRecursive(view: $0, color: color)
        }
    }
}
