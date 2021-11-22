//
//  AppDelegateAdvertisementExtension.swift
//  ios
//
//  Created by Maarten Vergouwe on 22/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

extension AppDelegate {
    internal func loadAdvertisements() {
        struct AdLoading { // Swift doesn't allow function scoped static variables
            static var initialLoadAdvertisement = true
        }
        
        DispatchQueue.global(qos: .utility).async {
            do {
                let lastDate = try Mediater.shared.send(request: GetAdvertisementsLastDateQuery())
                try Mediater.shared.sendAsync(request: ImportAdvertisementsCommand(lastChangedDate: lastDate)) { }
            } catch {
                print("Error happened while trying to update advertisements")
            }
        }
    
        if AdLoading.initialLoadAdvertisement {
            NotificationCenter.default.addObserver(self, selector: #selector(connectionStatusDidChange(notification:)), name: .GivtConnectionStateDidChange, object: nil)
            AdLoading.initialLoadAdvertisement = false
        }
    }
    
    @objc private func connectionStatusDidChange(notification: Notification) {
        if let canSend = notification.object as? Bool, canSend {
            loadAdvertisements()
        }
    }
}
