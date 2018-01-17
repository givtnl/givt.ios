//
//  SettingsItemTableViewCell.swift
//  ios
//
//  Created by Lennie Stockman on 11/07/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class SettingsItemTableViewCell: UITableViewCell {
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var settingImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

class SettingsItemBadgeAndArrow: SettingsItemTableViewCell {
    @IBOutlet weak var arrow: UIView!
    @IBOutlet weak var badge: UIImageView!
}

class SettingsItemArrow: SettingsItemTableViewCell {
    @IBOutlet weak var arrow: UIView!
}

class HighlightedItem: SettingsItemTableViewCell {
    
}
