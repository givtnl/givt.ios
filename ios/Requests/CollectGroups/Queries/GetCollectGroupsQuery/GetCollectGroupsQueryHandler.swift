//
//  GetCollectGroupsQueryHandler.swift
//  ios
//
//  Created by Maarten Vergouwe on 16/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

internal struct GetCollectGroupsQueryHandler : RequestHandlerProtocol {
    let apiClient = APIClient.shared
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
//        apiClient.get(url: "/api/v2/collectgroups", data: [:]) { response in
//            if let response = response, response.basicStatus == .ok {
//                let decoder = JSONDecoder()
//                do {
//                    try completion(try decoder.decode([CollectGroupDetailModel].self, from: response.data!) as! R.TResponse)
//                } catch {}
//            }
//        }
//        try? completion([CollectGroupDetailModel]() as! R.TResponse)
        var collectGroups = [CollectGroupDetailModel]()
        collectGroups.append(CollectGroupDetailModel(namespace: "61f7ed014e4c0720c000", name: "Mijn kerk", type: .church, paymentType: .SEPADirectDebit))
        collectGroups.append(CollectGroupDetailModel(namespace: "61f7ed014e4c0720c000", name: "De stichting", type: .charity, paymentType: .SEPADirectDebit))
        collectGroups.append(CollectGroupDetailModel(namespace: "61f7ed014e4c0720c000", name: "Een artiest", type: .artist, paymentType: .SEPADirectDebit))
        try? completion(collectGroups as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is GetCollectGroupsQuery
    }
}
