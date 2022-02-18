//
//  StringHelper.swift
//  ios
//
//  Created by Mike Pattyn on 18/02/2022.
//  Copyright © 2022 Givt. All rights reserved.
//

import Foundation
import UIKit

class StringHelper {
    static func getAttributedTextWithBoldCollectGroupName(_ message: String, _ collectGroupName: String) -> NSAttributedString {
        let lightAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Avenir-Light", size: 17)!,
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        ] as [NSAttributedString.Key : Any]
        let boldAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Avenir-Heavy", size: 17)!,
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        ] as [NSAttributedString.Key : Any]
        
        let rangeOfSubstring = (message as NSString).range(of: collectGroupName)
        let attributedString = NSMutableAttributedString(string: message, attributes: lightAttributes)
        attributedString.setAttributes(boldAttributes, range: rangeOfSubstring)
        return attributedString
    }
    
    static func getMessageWithCollectGroupName(_ message: String, _ collectGroupName: String) -> String {
        return message.replace("{0}", with: collectGroupName)
    }
}
