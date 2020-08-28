//
//  RecurringRuleViewModel.swift
//  ios
//
//  Created by Jonas Brabant on 27/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

internal class RecurringRuleViewModel {
    public var nameSpace:String = ""
    public var organisationName:String = ""
    public var cronExpression:String = ""
    public var amountPerTurn:Double = 0.0
    public var startDate:CLong = 0
    public var endsAfterTurns:Int = 0
    public var highLight:Bool = false
}
