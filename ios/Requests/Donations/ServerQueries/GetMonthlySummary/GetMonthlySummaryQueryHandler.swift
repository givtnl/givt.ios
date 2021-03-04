//
//  GetMonthlySummaryQueryHandler.swift
//  ios
//
//  Created by Mike Pattyn on 23/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class GetMonthlySummaryQueryHandler: RequestHandlerProtocol {
    private var client = APIClient.shared

    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let query = request as! GetMonthlySummaryQuery
        
        var route: String = "/api/v2/users/\(String(describing: UserDefaults.standard.userExt!.guid))/summary?groupType=\(query.groupType)&fromDate=\(query.fromDate)&tillDate=\(query.tillDate)&orderType=\(query.orderType)"
        
        route += "&transactionstatusses=1&transactionstatusses=2&transactionstatusses=3"
        
        client.get(url: route, data: [:]) { (response) in
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
        return request is GetMonthlySummaryQuery
    }
}
