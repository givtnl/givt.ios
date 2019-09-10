//
//  MediumHelper.swift
//  ios
//
//  Created by Maarten Vergouwe on 19/08/2019.
//  Copyright © 2019 Givt. All rights reserved.
//

import Foundation

class MediumHelper {
    static let churchRegExp = "c[0-9a-f]|d[be]"
    static let charityRegExp = "d[0-9acdf]"
    static let actionRegExp = "a[0-9a-f]"
    static let artistRegExp = "b[0-9a-f]"

    enum OrganisationType: Int {
        case invalid = -1
        case church = 0
        case charity = 1
        case campaign = 2
        case artist = 3
    }
    
    static func namespaceToOrganisationType(namespace: String) -> OrganisationType {
        let type = namespace.substring(16..<19)
        if type.matches(churchRegExp) {
            return .church
        } else if type.matches(charityRegExp) {
            return .charity
        } else if type.matches(actionRegExp) {
            return .campaign
        } else if type.matches(artistRegExp) {
            return .artist
        } else {
            return .invalid
        }        
    }
}
