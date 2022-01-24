//
//  GetPublicMetaQueryHandler.swift
//  ios
//
//  Created by Maarten Vergouwe on 20/01/2022.
//  Copyright © 2022 Givt. All rights reserved.
//

import Foundation

class GetUserHasDonationsQueryHandler : RequestHandlerProtocol {
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let request = request as! GetUserHasDonations
        
        if let hasDonations = UserDefaults.standard.hasDonations {
            try completion(hasDonations as! R.TResponse)
        } else {
            APIClient.shared.get(url: "/api/v2/users/\(request.userId)/givts/public-meta?year=\(Date().getYear())", data: [:]) { response in
                if let response = response, response.isSuccess,
                    let data = response.data,
                    let model = try? JSONDecoder().decode(DonationMetaModel.self, from: data) {
                    UserDefaults.standard.hasDonations = model.YearsWithGivts.count > 0
                    try? completion((model.YearsWithGivts.count > 0) as! R.TResponse)
                } else {
                    try? completion(false as! R.TResponse)
                }
            }
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        request is GetUserHasDonations
    }
}
