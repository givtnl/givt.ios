//
//  ChooseContextTableViewCell.swift
//  ios
//
//  Created by Lennie Stockman on 5/04/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit

class ChooseContextTableViewCell: UITableViewCell {

    @IBOutlet var img: UIImageView!
    @IBOutlet var name: UILabel!
    var contextType: ContextType!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            switch contextType {
            case .collectionDevice:
                contentView.backgroundColor = #colorLiteral(red: 0.09803921569, green: 0.4196078431, blue: 0.7098039216, alpha: 0.3006207192)
            case .qr:
                contentView.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.4392156863, blue: 0.3411764706, alpha: 0.3)
            case .manually:
                contentView.backgroundColor = #colorLiteral(red: 1, green: 0.6917269826, blue: 0, alpha: 0.3)
            case .none:
                break
            case .some(_):
                break
            }
        } else {
            contentView.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 0.15)
        }
       
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsetsMake(0, 0, 8, 0))

    }

}
