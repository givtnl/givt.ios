//
//  GetCountryQueryHandler.swift
//  ios
//
//  Created by Mike Pattyn on 17/09/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

internal struct GetCountryQueryHandler : RequestHandlerProtocol {
    private var client = APIClient.shared

    public func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        var retVal: String? = nil
        if let country = AppServices.getCountryFromSim() {
            retVal = country
        } else {
            LoginManager.shared.getUserExt { (userExtObject) in
                if let country = userExtObject?.Country {
                    retVal = country
                }
            }
            if retVal == nil {
                throw GetCountryError.CouldNotGetCountryFromUser
            }
        }
        try completion(retVal as! R.TResponse)
    }
    
    public func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is GetCountryQuery
    }
}
