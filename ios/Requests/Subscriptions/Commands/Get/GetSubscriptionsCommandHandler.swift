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
        
        
        client.get(url: "https://api.development.givtapp.net/subscriptions?userId=subscriptions?userId=\(UserDefaults.standard.userExt!.guid)", data: [:]) { (response) in
            let models: [RecurringRuleViewModel] = []
            if let response = response, let data = response.data, response.statusCode == 200 {
                do
                {
                    let parsedData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
//                    for x in parsedData {
//                        models.append(HistoryTransaction(dictionary: x as Dictionary<String, Any>)!)
//                    }
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
