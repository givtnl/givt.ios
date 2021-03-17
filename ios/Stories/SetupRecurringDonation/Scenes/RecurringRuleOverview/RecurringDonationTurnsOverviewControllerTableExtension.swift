//
//  RecurringDonationTurnsOverviewTableExtension.swift
//  ios
//
//  Created by Mike Pattyn on 17/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

extension RecurringDonationTurnsOverviewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return donationsByYearSorted![section].value.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RecurringDonationTurnTableCell.self), for: indexPath) as! RecurringDonationTurnTableCell
        
        cell.viewModel = donationsByYearSorted![indexPath.section].value[indexPath.row]
        
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if(donationsByYearSorted != nil) {
            return donationsByYearSorted!.count
        }
        else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let title = UILabel()
        title.textColor = UIColor.red
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel!.font = title.font
        header.textLabel!.textColor = title.textColor
        header.contentView.backgroundColor = UIColor.white
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header_cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableSectionHeaderRecurringRuleOverviewView") as! TableSectionHeaderRecurringRuleOverview
        
        header_cell.opaqueLayer.isHidden = true
        
        let giftsFromSameYear = donationsByYearSorted![section]
        let giftsFromSameYear_First = giftsFromSameYear.value.first
        let year : Int = Int(giftsFromSameYear_First!.year)!
        
        if(giftsFromSameYear.key == 9999 && giftsFromSameYear_First!.toBePlanned) {
        
            if(donationsByYearSorted![section].value.count > 0) {
                if (donationsByYearSorted!.count == 1) {
                    header_cell.year.text = "RecurringDonationFutureDetailDifferentYear".localized + " " + String(year)
                }
                else if(donationsByYearSorted!.count > 1) {
                    let nextYear = donationsByYearSorted![section+1].key
                    if (nextYear == year) {
                        header_cell.year.text = "RecurringDonationFutureDetailSameYear".localized
                    } else {
                        header_cell.year.text = "RecurringDonationFutureDetailDifferentYear".localized + " " + String(year)
                    }
                }
            }
            else {
                header_cell.isHidden = true
            }
        }
        else {
            header_cell.year.text = "\(year)"
        }
        
        return header_cell
    }

}
