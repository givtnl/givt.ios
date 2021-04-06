//
//  GetExternalMonthlySummaryQueryHandler.swift
//  ios
//
//  Created by Mike Pattyn on 29/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class GetExternalMonthlySummaryQueryHandler: RequestHandlerProtocol {
    private var client = APIClient.cloud

    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let query = request as! GetExternalMonthlySummaryQuery
        
        let route: String = "/external-donations/summary?groupType=\(query.groupType)&fromDate=\(query.fromDate)&tillDate=\(query.tillDate)&orderType=\(query.orderType)"
                
        client.get(url: route, data: [:], headers: ["x-json-casing": "PascalKeeze"]) { (response) in
            var models: [MonthlySummaryDetailModel] = []
            if let response = response, response.isSuccess {
                if let body = response.text {
                    do {
                        let decoder = JSONDecoder()
                        models = try decoder.decode([MonthlySummaryDetailModel].self, from: Data(body.utf8))
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
        return request is GetExternalMonthlySummaryQuery
    }
}
