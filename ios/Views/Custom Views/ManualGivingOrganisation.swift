//
//  ManualGivingOrganisation.swift
//  ios
//
//  Created by Lennie Stockman on 12/01/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit

class ManualGivingOrganisation: UITableViewCell {

    public var nameSpace: String = ""
    @IBOutlet var checkMark: UIImageView!
    @IBOutlet var organisationLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func toggleOff() {
        checkMark.alpha = 0
    }
    func toggleOn() {
        checkMark.alpha = 1
    }

}
