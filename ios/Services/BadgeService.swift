//
//  BadgeService.swift
//  ios
//
//  Created by Lennie Stockman on 13/09/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
import UIKit

class BadgeService {
    enum Badge: Int {
        case completeRegistration
        case offlineGifts
    }
    
    static let shared = BadgeService()
    
    private var badges: [Int]!
    
    init() {
        badges = UserDefaults.standard.badges
        UIApplication.shared.applicationIconBadgeNumber = badges.count
    }

    func addBadge(badge: Badge) {
        if !badges.contains(badge.rawValue) {
            badges.append(badge.rawValue)
            refreshCount()
        }
    }
    
    func removeBadge(badge: Badge) {
        if let idx = badges.index(of: badge.rawValue) {
            badges.remove(at: idx)
            refreshCount()
        }
    }
    
    func refreshCount() {
        UserDefaults.standard.badges = badges
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = self.badges.count
        }
    }
}
