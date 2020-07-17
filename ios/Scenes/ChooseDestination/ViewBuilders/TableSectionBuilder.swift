//
//  TableSectionBuilder.swift
//  ios
//
//  Created by Maarten Vergouwe on 16/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

internal class TableSectionBuilder {
    static func build(input: [DestinationViewModel]) -> [TableSection] {
        if input.count > 0 {
            let names = input.map { vm in
                return vm.name
            }
            var firstCharacters = names.map { name in
                return name.first!
            }
            firstCharacters = Array(Set(firstCharacters)).sorted()
            return firstCharacters.map { fc in
                let firstNameWithCharacter = names.sorted().firstIndex { name in
                    return String(name.first!) == String(fc)
                }
                let lastNameWithCharacter = names.sorted().lastIndex { name in
                    return String(name.first!) == String(fc)
                }
                return TableSection(index: firstNameWithCharacter!, length: lastNameWithCharacter! - firstNameWithCharacter! + 1, title: String(fc))
            }
        }
        return [TableSection]()
    }
}
