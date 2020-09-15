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
    public var collectGroupName: String?
    public var endsAfterTurns: Int = 0
    public var id: String = ""
    public var currentState: RecurringDonationState?
    public var cronExpression: String = ""
    public var amountPerTurn: Double = 0.0
    public var startDate: String = ""
    public var collectGroupType: CollectGroupType?
    public var indexPath: IndexPath?
    public var shouldShowNewItemMarker: Bool? = false
}

extension RecurringRuleViewModel {
    func getEndDateFromRule() -> Date {
        let multiplier = endsAfterTurns-1
        var dateComponent = DateComponents()
        switch getFrequencyFromCron() {
            case "SetupRecurringGiftWeek".localized:
                dateComponent.weekOfYear = multiplier
            case "SetupRecurringGiftMonth".localized:
                dateComponent.month = multiplier
            case "SetupRecurringGiftQuarter".localized:
                dateComponent.month = multiplier * 3
            case "SetupRecurringGiftHalfYear".localized:
                dateComponent.month = multiplier * 6
            case "SetupRecurringGiftYear".localized:
                dateComponent.year = multiplier
            default:
                break
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return Calendar.current.date(byAdding: dateComponent, to: dateFormatter.date(from: startDate)!)!
    }
    func getFrequencyFromCron() -> String {
        let elements = cronExpression.split(separator: " ")
        let day = elements[2]
        let month = elements[3]
        let dayOfWeek = elements[4]
        var frequency: String = ""
        if (dayOfWeek != "*") {
            frequency = "SetupRecurringGiftWeek".localized
        } else if (day != "*") {
            if (month == "*") {
                frequency = "SetupRecurringGiftMonth".localized
            }
            if (month.contains("/3")) {
                frequency = "SetupRecurringGiftQuarter".localized
            }
            if (month.contains("/6")) {
                frequency = "SetupRecurringGiftHalfYear".localized
            }
            if (month.contains("/12")) {
                frequency = "SetupRecurringGiftYear".localized
            }
        }
        return frequency
    }
}

struct RecurringRulesResponseModel: Codable {
    public var count: Int = 0
    public var results: [RecurringRuleViewModel] = []
}
