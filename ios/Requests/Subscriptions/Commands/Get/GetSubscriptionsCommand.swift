//
//  GetSubscriptionsCommand.swift
//  ios
//
//  Created by Jonas Brabant on 29/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

class GetSubscriptionsCommand : Codable, RequestProtocol {
    typealias TResponse = [RecurringRuleViewModel]
}
