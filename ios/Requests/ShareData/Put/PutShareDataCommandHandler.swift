//
//  PutShareDataCommandHandler.swift
//  ios
//
//  Created by Mike Pattyn on 07/11/2022.
//  Copyright © 2022 Givt. All rights reserved.
//

import Foundation
import GivtCodeShare

class PutShareDataCommandHandler: RequestHandlerProtocol {
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let request = (request as! PutShareDataCommand)
        let body = ShareUserDataCommandBody(shareData: request.shareData)
        GivtApi.User().putShareUserData(
            userId: UserDefaults.standard.userExt!.guid,
            bearerToken: UserDefaults.standard.bearerToken!,
            putShareUserDataCommandBody: body) { (result, err) in
            try? completion(true as! R.TResponse)
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is PutShareDataCommand
    }
}
