//
//  ArrayExtensions.swift
//  ios
//
//  Created by Lennie Stockman on 12/01/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
extension Array where Element : Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
}
