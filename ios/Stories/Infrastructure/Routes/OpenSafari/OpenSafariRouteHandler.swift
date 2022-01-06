//
//  DiscoverOrAmountOpenSafariRouteHandler.swift
//  ios
//
//  Created by Mike Pattyn on 29/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class OpenSafariRouteHandler : RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let request = request as! OpenSafariRoute
        
        var message = "SafariGiving".localized
        if let _ = request.mandateUrl {
            message = "Safari_GivtTransaction".localized
        } else if let cgName = request.collectGroupName {
            message = "SafariGivingToOrganisation".localized.replacingOccurrences(of:"{0}", with: cgName)
        }
        
        var safariModel = OpenSafariRouteInputModel(
            message: message,
            Collect: "Collect".localized,
            AreYouSureToCancelGivts: "AreYouSureToCancelGivts".localized,
            ConfirmBtn: request.mandateUrl == nil ? "Confirm".localized : "Next".localized,
            Cancel: "Cancel".localized,
            SlimPayInformation: "SlimPayInformation".localized,
            SlimPayInformationPart2: "SlimPayInformationPart2".localized,
            Close: "Close".localized,
            ShareGivt: "ShareTheGivtButton".localized,
            Thanks: "GivtIsBeingProcessed".localized.replacingOccurrences(of: "{0}", with: request.collectGroupName ?? ""),
            YesSuccess: "YesSuccess".localized,
            GUID: request.userId.uuidString,
            givtObj: request.donations.map { OpenSafariRouteTransactionModel(Amount: $0.amount, CollectId: $0.collectId, Timestamp: $0.timeStamp, BeaconId: $0.beaconId)},
            apiUrl: "\(AppConstants.apiUri)/",
            organisation: request.collectGroupName,
            spUrl: request.mandateUrl,
            canShare: true,
            nativeAppScheme: AppConstants.appScheme,
            urlPart: AppConstants.returnUrlDir,
            currency: CurrencyHelper.shared.getCurrencySymbol(),
            country: request.country
        )
        if let ad = request.advertisement {
            safariModel.advertisementText = ad.text
            safariModel.advertisementTitle = ad.title
            safariModel.advertisementImageUrl = ad.imageUrl
        }
        
        let plainTextBytes = try JSONEncoder().encode(safariModel).base64EncodedString()
        let gotoUrl = URL(string: "\(AppConstants.apiUri)/confirm.html?msg=\(plainTextBytes)")!;
        LogService.shared.info(message: "Going to Safari")
        
        let safariViewController = SFSafariViewController(url: gotoUrl)
        safariViewController.delegate = request.delegate
        safariViewController.modalPresentationStyle = .popover
        context.show(safariViewController, sender: context)
        try completion(safariViewController as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is OpenSafariRoute
    }
}
