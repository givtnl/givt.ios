//
//  GetCollectGroupsV2QueryHandler.swift
//  ios
//
//  Created by Mike Pattyn on 15/02/2022.
//  Copyright © 2022 Givt. All rights reserved.
//

import Foundation

class GetCollectGroupsV2QueryHandler: RequestHandlerProtocol {
    private let client = APIClient.shared
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let retVal = ResponseModel<BeaconList?>(result: nil, error: .notFound)
        client.get(url: "/api/v2/collectgroups/applist-v2", data: [:], timeout: 20) { response in
            if let response = response, response.isSuccess, let body = response.text {
                if let appList = try? JSONDecoder().decode(CollectGroupAppListModel.self, from: Data(body.utf8)) {
                    retVal.result = BeaconListHelper.convertFromMinifiedList(minifiedList: appList)
                    try? completion(retVal as! R.TResponse)
                } else {
                    try? completion(retVal as! R.TResponse)
                }
            } else {
                try? completion(retVal as! R.TResponse)
            }
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        request is GetCollectGroupsV2Query
    }
}
