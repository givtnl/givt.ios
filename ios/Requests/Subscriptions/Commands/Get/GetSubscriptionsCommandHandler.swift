//
//  GetSubscriptionsCommandHandler.swift
//  ios
//
//  Created by Jonas Brabant on 29/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class GetSubscriptionsCommandHandler : RequestHandlerProtocol {
    private var client = APIClient.shared
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        
        client.get(url: "https://api.development.givtapp.net/subscriptions?userId=subscriptions", data: [:]) { (response) in
            var models: [RecurringRuleViewModel] = []
            if let response = response, let data = response.data, response.statusCode == 200 {
                do
                {
                    let parsedData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                    if let parsedDataResult = parsedData["results"] as? [Dictionary<String, Any>] {
                        for x in parsedDataResult {
                            let item:RecurringRuleViewModel = RecurringRuleViewModel()
                            item.amountPerTurn = x["amountPerTurn"] as! Double
                            item.cronExpression = x["cronExpression"] as! String
                            item.currentState = x["currentState"] as! Int
                            item.endsAfterTurns = x["endsAfterTurns"] as! Int
                            item.id = x["id"] as! String
                            item.nameSpace = x["namespace"] as! String
                            item.startDate = x["startDate"] as! Int
                            models.append(item)
                        }
                    }
                    try? completion(models as! R.TResponse)
                } catch {
                    try? completion(models as! R.TResponse)
                }
            } else {
                try? completion(models as! R.TResponse)
            }
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is GetSubscriptionsCommand
    }
}
