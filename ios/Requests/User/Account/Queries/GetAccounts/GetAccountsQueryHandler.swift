//
//  GetCreditCardQueryHandler.swift
//  ios
//
//  Created by Mike Pattyn on 25/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import GivtCodeShare

class GetAccountsQueryHandler: RequestHandlerProtocol {
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let responseModel = ResponseModel<[AccountDetailModel]?>(result: nil, error: .unknown)
        guard let userId: String = UserDefaults.standard.userExt?.guid else {
            try? completion(responseModel as! R.TResponse)
            return
        }
        GivtApi.UserAccounts().getAccounts(userId: userId, bearerToken: UserDefaults.standard.bearerToken!) { accounts, error in
            if let accounts = accounts {
                responseModel.result = accounts
            } else {
                responseModel.error = .notFound
            }
            try? completion(responseModel as! R.TResponse)
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is GetAccountsQuery
    }
}
