//
//  LineWithButton.swift
//  ios
//
//  Created by Mike Pattyn on 27/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class LineWithButton : UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var addButton: CustomButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func commonInit() {
        let bundle = Bundle(for: LineWithButton.self)
        bundle.loadNibNamed("LineWithButton", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.layer.frame
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.isUserInteractionEnabled = false
        addButton.ogBGColor = ColorHelper.LightGreenChart
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        print("Add button pressed")
    }
}
