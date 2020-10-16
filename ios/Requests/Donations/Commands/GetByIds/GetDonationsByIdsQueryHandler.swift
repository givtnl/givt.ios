//
//  GetRecurringDonationTurnsDetailQueryHandler.swift
//  ios
//
//  Created by Mike Pattyn on 13/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import SwiftClient

class GetDonationsByIdsQueryHandler : RequestHandlerProtocol {
    private var client = APIClient.shared
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let query = request as! GetDonationsByIdsQuery
        
        let route: String = getRouteWithParams(route: "/api/givts", ids: query.ids.map{String($0)})
        
        client.get(url: route, data: [:]) { (response) in
            var models: [DonationResponseModel] = []
            if let response = response, response.isSuccess {
                if let body = response.text {
                    do {
                        let decoder = JSONDecoder()
                        models = try decoder.decode(Array<DonationResponseModel>.self, from: Data(body.utf8)).sorted(by: { (first, second) -> Bool in
                            return first.Timestamp.toDate! < second.Timestamp.toDate!
                        })
                        
                    } catch {
                        print("\(error)")
                    }
                    try? completion(models as! R.TResponse)
                }
            } else {
                try? completion(models as! R.TResponse)
            }
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is GetDonationsByIdsQuery
    }
    
    private func getRouteWithParams(route: String, ids: [String]) -> String {
        var tempIds = ids
        var paramString: String = "\(route)?ids="
        paramString += tempIds.joined(separator: "&ids=")
        return paramString
    }
}
