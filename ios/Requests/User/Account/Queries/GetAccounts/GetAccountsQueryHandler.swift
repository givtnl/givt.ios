//
//  GetCreditCardQueryHandler.swift
//  ios
//
//  Created by Mike Pattyn on 25/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

typealias AccountsArray = [AccountsDetailModel]
class GetAccountsQueryHandler: RequestHandlerProtocol {
    private var client = APIClient.shared
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let responseModel = ResponseModel<GetAccountsResponseModel?>(result: nil, error: .unknown)
        guard let userId: String = UserDefaults.standard.userExt?.guid else {
            try? completion(responseModel as! R.TResponse)
            return
        }
        
        client.get(url: "/api/v2/users/\(userId)/accounts", data: [:]) { response in
            if let response = response, response.isSuccess {
                if let data = response.data {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String:Any]] {
                        responseModel.result = GetAccountsResponseModel.fromDictionaryStringAny(dictionary: json)
                    } else {
                        responseModel.error = .parseError
                    }
                }
            }
            try? completion(responseModel as! R.TResponse)
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is GetAccountsQuery
    }
}
