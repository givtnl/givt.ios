//
//  GetRecurringDonationsQueryHandler.swift
//  ios
//
//  Created by Jonas Brabant on 29/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class GetRecurringDonationsQueryHandler : RequestHandlerProtocol {
    private var client = APIClient.cloud
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        
        client.get(url: "/subscriptions", data: [:]) { (response) in
            var models: [RecurringRuleViewModel] = []
            if let response = response, response.isSuccess {
                if let body = response.text {
                    do {
                        let decoder = JSONDecoder()
                        let parsedDataResult = try decoder.decode(RecurringRulesResponseModel.self, from: Data(body.utf8))
                        models = parsedDataResult.results.filter({ (model) -> Bool in
                            model.currentState != 0
                        })
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
        return request is GetRecurringDonationsQuery
    }
}
