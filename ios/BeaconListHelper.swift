//
//  BeaconListHelper.swift
//  ios
//
//  Created by Mike Pattyn on 15/02/2022.
//  Copyright © 2022 Givt. All rights reserved.
//

import Foundation
import GivtCodeShare

class BeaconListHelper {    
    static func convertFromMinifiedList(minifiedList: CollectGroupAppListModel) -> BeaconList {
        var orgBeacons = [OrgBeacon]()
        minifiedList.CGS.forEach { collectGroupDetailModel in
            let orgBeacon = OrgBeacon(
                EddyNameSpace: collectGroupDetailModel.NS,
                OrgName: collectGroupDetailModel.N,
                Celebrations: collectGroupDetailModel.C,
                Locations: collectGroupDetailModel.L?.map({ locationDetailModel in
                    OrgBeaconLocation(
                        Name: locationDetailModel.N,
                        Latitude: locationDetailModel.LA,
                        Longitude: locationDetailModel.LO,
                        Radius: Int(locationDetailModel.R),
                        BeaconId: "\(collectGroupDetailModel.NS).\(locationDetailModel.I)",
                        dtBegin: locationDetailModel.DB.toDateWithFormat(format: "yyyy-MM-dd")!,
                        dtEnd: locationDetailModel.DE.toDateWithFormat(format: "yyyy-MM-dd")!
                    )
                }) ?? [OrgBeaconLocation](),
                QrCodes: collectGroupDetailModel.Q?.map({ qrCodeDetailModel in
                    QrCode(
                        Name: qrCodeDetailModel.N,
                        MediumId: "\(collectGroupDetailModel.NS).\(qrCodeDetailModel.I)",
                        Active: qrCodeDetailModel.A
                    )
                }) ?? [QrCode](),
                collectGroupType: CollectGroupType.init(rawValue: Int(collectGroupDetailModel.T)))
            orgBeacons.append(orgBeacon)
        }
        return BeaconList(OrgBeacons: orgBeacons, LastChanged: Date())
    }
}
