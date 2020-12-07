//
//  GetCollectGroupsQueryPreProcessor.swift
//  ios
//
//  Created by Mike Pattyn on 07/12/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

class GetCollectGroupsQueryPreProcessor: RequestPreProcessorProtocol {
    func handle<R>(request: R, completion: @escaping (R) throws -> Void) throws where R : RequestProtocol {
        
        if GivtManager.shared.orgBeaconList == nil {
            // setting this because orgBeaconList in the GivtManager is a read only
            UserDefaults.standard.orgBeaconListV2 = loadFromJsonFile()
        }
        try completion(request)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is GetCollectGroupsQuery
    }
    
    fileprivate func loadFromJsonFile() -> BeaconList {
        var jsonFileName = "collectGroupsList"
        #if DEBUG
            jsonFileName += "Debug"
        #endif
        
        let jsonFilePath = Bundle.main.path(forResource: jsonFileName, ofType: "json")!
        let jsonData = try? String(contentsOfFile: jsonFilePath).data(using: .utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ (date) -> Date in
            let container = try date.singleValueContainer()
            var dateStr = try container.decode(String.self)
            dateStr = dateStr.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            return dateFormatter.date(from: dateStr) ?? Date(timeIntervalSince1970: 0)
        })
        return try! decoder.decode(BeaconList.self, from: jsonData!)
    }
}
