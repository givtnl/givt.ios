//
//  CollectionExtensions.swift
//  ios
//
//  Created by Lennie Stockman on 12/01/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
extension Collection where Iterator.Element == String {
    var initials: [String] {
        return map{String($0.characters.prefix(1))}
    }
}
