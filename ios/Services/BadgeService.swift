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
    
    private init() {
        badges = UserDefaults.standard.badges
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = self.badges.count
        }
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
    
    func hasBadge(badge: Badge) -> Bool {
        return badges.contains(badge.rawValue)
    }
    
    func removeAllBadges() -> Void {
        badges.removeAll()
        refreshCount()
    }
    
    private func refreshCount() {
        UserDefaults.standard.badges = badges
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = self.badges.count
        }
        NotificationCenter.default.post(name: .GivtBadgeNumberDidChange, object: nil)
    }
    
}
