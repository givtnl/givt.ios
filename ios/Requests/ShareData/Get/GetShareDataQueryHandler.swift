//
//  GetShareDataQueryHandler.swift
//  ios
//
//  Created by Mike Pattyn on 07/11/2022.
//  Copyright © 2022 Givt. All rights reserved.
//

import Foundation
import GivtCodeShare

class GetShareDataQueryHandler: RequestHandlerProtocol {    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        GivtApi.User().getShareUserData(userId: UserDefaults.standard.userExt!.guid, bearerToken: UserDefaults.standard.bearerToken!) { result, err in
            if result != nil {
                try? completion(result as! R.TResponse)
            } else {
                try? completion(false as! R.TResponse)
            }
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        request is GetShareDataQuery
    }
}
