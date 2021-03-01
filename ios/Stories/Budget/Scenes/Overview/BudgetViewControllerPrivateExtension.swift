//
//  BudgetViewControllerPrivateExtension.swift
//  ios
//
//  Created by Mike Pattyn on 01/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation


//MARK: Private extension - used to store private methods and actions
private extension BudgetViewController {
    @IBAction func backButton(_ sender: Any) {
        try? Mediater.shared.send(request: BackToMainRoute(), withContext: self)
    }
    @IBAction func giveNowButton(_ sender: Any) {
        try? Mediater.shared.send(request: OpenGiveNowRoute(), withContext: self)
    }
    @IBAction func buttonSeeMore(_ sender: Any) {
        print("See more pressed")
    }
    @IBAction func buttonPlus(_ sender: Any) {
        try? Mediater.shared.send(request: OpenExternalGivtsRoute(), withContext: self)
    }

    private func getMonthStringFromIntValue(value: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: getDateFromInt(value: value)).replacingOccurrences(of: ".", with: String.empty)
    }
    private func getDateFromInt(value: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = value
        return Calendar.current.date(from: dateComponents)!
    }
    private func createDateByMonthAndYear(month: Int, year: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = month
        dateComponents.year = year
        return Calendar.current.date(from: dateComponents)!
    }
}
