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
        if let country = AppServices.getCountryFromSim() {
            try? completion(country as! R.TResponse)
        } else {
            LoginManager.shared.getUserExt { (userExtObject) in
                if let userExt = userExtObject {
                    try? completion(userExt.Country as! R.TResponse)
                } else {
                    try? completion(Locale.current.regionCode! as! R.TResponse)
                }
            }            
        }
    }
    
    public func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is GetCountryQuery
    }
}
