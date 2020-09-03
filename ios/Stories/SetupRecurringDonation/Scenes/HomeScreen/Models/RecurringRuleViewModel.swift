//
//  RecurringRuleViewModel.swift
//  ios
//
//  Created by Jonas Brabant on 27/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

struct RecurringRuleViewModel: Codable {
    public var namespace: String = ""
    public var endsAfterTurns: Int = 0
    public var id: String = ""
    public var currentState: Int = 0
    public var cronExpression: String = ""
    public var amountPerTurn: Double = 0.0
    public var startDate: Int = 0
}

struct RecurringRulesResponseModel: Codable {
    public var count: Int = 0
    public var results: [RecurringRuleViewModel] = []
}
