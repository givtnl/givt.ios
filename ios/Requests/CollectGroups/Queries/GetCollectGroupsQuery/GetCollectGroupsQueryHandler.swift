//
//  GetCollectGroupsQueryHandler.swift
//  ios
//
//  Created by Maarten Vergouwe on 16/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

internal struct GetCollectGroupsQueryHandler : RequestHandlerProtocol {    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let collectGroups = GivtManager.shared.orgBeaconList!.map { (orgBeacon) -> CollectGroupDetailModel in
            var type = CollectGroupType.church
            switch MediumHelper.namespaceToOrganisationType(namespace: orgBeacon.EddyNameSpace) {
            case .church:
                type = .church
            case .charity:
                type = .charity
            case .campaign:
                type = .campaign
            case .artist:
                type = .artist
            default:
                break
            }
            return CollectGroupDetailModel(namespace: orgBeacon.EddyNameSpace,
                                    name: orgBeacon.OrgName,
                                    type: type,
                                    paymentType: orgBeacon.accountType == AccountType.sepa ? PaymentType.SEPADirectDebit : PaymentType.BACSDirectDebit)
            
        }
        
        try? completion(collectGroups as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is GetCollectGroupsQuery
    }
}
