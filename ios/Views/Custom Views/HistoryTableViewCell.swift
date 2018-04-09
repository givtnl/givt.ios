//
//  HistoryTableViewCell.swift
//  ios
//
//  Created by Lennie Stockman on 20/03/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit
import SwipeCellKit

class HistoryTableViewCell: SwipeTableViewCell {  

    @IBOutlet var agendaRectangle: UIView!
    @IBOutlet var statusBullet: UIView!
    @IBOutlet var statusView: UIView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var dayNumber: UILabel!
    @IBOutlet var collections: UIStackView!
    @IBOutlet var collectLabel: UILabel!
    @IBOutlet var organisationLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(roundedRect:agendaRectangle.bounds,
                                byRoundingCorners:[.topLeft, .topRight],
                                cornerRadii: CGSize(width: 2.5, height:  2.5))
        
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = path.cgPath
        agendaRectangle.layer.mask = maskLayer
    }
    
    func setColor(status: Int) {
        switch status {
        case 1, 2:
            statusView.backgroundColor = UIColor.init(rgb: 0x2c2b57) //in process
        case 3:
            statusView.backgroundColor = UIColor.init(rgb: 0x41c98e) //processed
        case 4:
            statusView.backgroundColor = UIColor.init(rgb: 0xd43d4c) //refused
        case 5:
            statusView.backgroundColor = UIColor.init(rgb: 0xbcb9c9) //cancelled
        default:
            statusView.backgroundColor = UIColor.init(rgb: 0x2c2b57) //in process
            break
        }
    }

    func setCollects(collects: [Collecte]) {
        collections.arrangedSubviews.forEach { (view) in
            if let sv = view as? UIStackView {
                sv.removeConstraints(sv.constraints)
                sv.removeFromSuperview()
            }
            view.removeConstraints(view.constraints)
            view.removeFromSuperview()
        }
        
        collects.forEach { (collecte) in
            let hsv = UIStackView()
            hsv.axis = .horizontal
            hsv.distribution = .fillProportionally
            hsv.alignment = .top
            hsv.translatesAutoresizingMaskIntoConstraints = false

            collections.addArrangedSubview(hsv)
            hsv.leadingAnchor.constraint(equalTo: collections.leadingAnchor).isActive = true
            hsv.trailingAnchor.constraint(equalTo: collections.trailingAnchor).isActive = true
            
            let label = UILabel()
            label.text = NSLocalizedString("Collect", comment: "") + " " + String(describing: collecte.collectId)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont(name: "Avenir-Light", size: 15)
            label.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
            
            let amount = UILabel()
            amount.text = collecte.amountString
            amount.translatesAutoresizingMaskIntoConstraints = false
            amount.font = UIFont(name: "Avenir-Light", size: 15)
            amount.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
            amount.textAlignment = .right
            hsv.addArrangedSubview(label)
            hsv.addArrangedSubview(amount)
        }

    }

}
