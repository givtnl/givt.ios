//
//  ExportDonationCommandHandler.swift
//  ios
//
//  Created by Maarten Vergouwe on 22/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import SwiftClient

class ExportDonationCommandHandler : RequestHandlerProtocol {
    let apiClient = APIClient.shared
        
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        DispatchQueue.global(qos: .userInitiated).async {
            let request = request as! ExportDonationCommand
            let donation = Transaction(amount: request.amount, beaconId: request.mediumId, collectId: request.collectId,
                                       timeStamp: request.timeStamp.toISOString(), userId: request.userId.uuidString)
            
            try? completion(self.tryGive(donation: JSONEncoder().encode(donation)) as! R.TResponse)
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is ExportDonationCommand
    }
    
    private func tryGive(donation: Data, tries: Int = 3) -> Bool {
        if tries == 0 {
            LogService.shared.error(message: "Impossible to post givt to server!")
            return false
        }
        
        let semaphore = DispatchSemaphore.init(value: 0)
        var retVal = false
        do {
            try apiClient.post(url: "/api/v2/givts", data: donation) { response in
                guard let response = response else {
                    retVal = false
                    semaphore.signal()
                    return
                }
                switch response.status {
                case .created:
                    LogService.shared.info(message: "Posted givt to server")
                    retVal = true
                case .expectationFailed:
                    LogService.shared.warning(message: "Received expectation failed from server. Removing donation from cache")
                    retVal = true
                default:
                    retVal = self.tryGive(donation: donation, tries: tries-1)
                }
                semaphore.signal()
            }
        } catch {
            return false
        }
        semaphore.wait()
        return retVal
    }
}
