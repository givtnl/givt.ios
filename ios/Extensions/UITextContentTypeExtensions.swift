//
//  UITextContentTypeExtensions.swift
//  ios
//
//  Created by Mike Pattyn on 19/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

extension UITextContentType {
    public static let expiryDate: UITextContentType = UITextContentType(rawValue: "Exp")
    public static let securityCode: UITextContentType = UITextContentType(rawValue: "CVV")
}
