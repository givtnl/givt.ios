//
//  GetAllExternalDonationsQueryHandler.swift
//  ios
//
//  Created by Mike Pattyn on 05/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class GetAllExternalDonationsQueryHandler: RequestHandlerProtocol {
    private var client = APIClient.cloud
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        var query = request as! GetAllExternalDonationsQuery
        client.get(url: "/external-donations?fromDate=\(query.fromDate)&tillDate=\(query.tillDate)", data: [:]) { (response) in
            var responseModel: ExternalDonationGetAllResultModel = ExternalDonationGetAllResultModel(result: [])
            
            if let response = response, response.isSuccess {
                if let body = response.text {
                    do {
                        let decoder = JSONDecoder()
                        responseModel = try decoder.decode(ExternalDonationGetAllResultModel.self, from: Data(body.utf8))
                    } catch {
                        print("\(error)")
                    }
                    try? completion(responseModel as! R.TResponse)
                }
            } else {
                try? completion(responseModel as! R.TResponse)
            }
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        request is GetAllExternalDonationsQuery
    }
}
