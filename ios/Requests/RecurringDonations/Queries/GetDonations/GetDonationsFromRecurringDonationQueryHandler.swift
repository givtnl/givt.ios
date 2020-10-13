//
//  GetDonationsFromRecurringDonationQueryHandler.swift
//  ios
//
//  Created by Mike Pattyn on 13/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//
import Foundation
import CoreData
import UIKit

class GetDonationsFromRecurringDonationQueryHandler : RequestHandlerProtocol {
    private var client = APIClient.cloud
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let query = request as! GetDonationsFromRecurringDonationQuery
        
        client.get(url: "/recurringdonations/"+query.id+"/donations", data: [:]) { (response) in
            var models: [RecurringDonationDonationViewModel] = []
            if let response = response, response.isSuccess {
                if let body = response.text {
                    do {
                        let decoder = JSONDecoder()
                        let parsedDataResult = try decoder.decode(GetDonationsFromRecurringDonationResponseModel.self, from: Data(body.utf8))
                        models = parsedDataResult.results
                    } catch {
                        try? completion(models as! R.TResponse)
                    }
                    try? completion(models as! R.TResponse)
                }
            } else {
                try? completion(models as! R.TResponse)
            }
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is GetDonationsFromRecurringDonationQuery
    }
}
