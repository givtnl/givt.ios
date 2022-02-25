//
//  PersonalSettingTableViewCell.swift
//  ios
//
//  Created by Lennie Stockman on 19/06/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit
import SwipeCellKit

class PersonalSettingTableViewCell: SwipeTableViewCell {

    @IBOutlet var img: UIImageView!
    @IBOutlet var labelView: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
