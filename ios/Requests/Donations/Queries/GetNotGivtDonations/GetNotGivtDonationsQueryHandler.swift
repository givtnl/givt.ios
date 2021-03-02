//
//  GetNotGivtDonationsQueryHandler.swift
//  ios
//
//  Created by Mike Pattyn on 02/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class GetNotGivtDonationsQueryHandler: RequestHandlerProtocol {
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let models: [NotGivtDonationModel] = [
            NotGivtDonationModel(guid: UUID().uuidString, name: "Rode kruis", amount: 50.0),
            NotGivtDonationModel(guid: UUID().uuidString, name: "Kom op tegen kanker", amount: 50.0)
        ]
        try? completion(models as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is GetNotGivtDonationsQuery
    }
}
