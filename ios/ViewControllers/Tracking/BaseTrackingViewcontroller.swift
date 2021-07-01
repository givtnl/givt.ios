//
//  BaseTrackingViewcontroller.swift
//  ios
//
//  Created by Mike Pattyn on 01/07/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
import Mixpanel

class BaseTrackingViewController: UIViewController {
    var screenName: String { return String.empty }
    lazy private var trackingProperties: [String: MixpanelType] = ["SCREEN_NAME": screenName]
    var customTrackingProperties: [String: MixpanelType]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let properties = customTrackingProperties != nil ? mergeDictionaries(trackingProperties, customTrackingProperties!) : trackingProperties
        trackEvent(event: "LOADED", properties: properties)
    }

    deinit {
        trackEvent(event: "DISMISSED", properties: trackingProperties)
    }
    
    func trackEvent(_ event: String, properties: [String: MixpanelType]) {
        let properties = mergeDictionaries(trackingProperties, properties)
        trackEvent(event: event, properties: properties)
    }
    
    private func trackEvent(event: String, properties: [String: MixpanelType]) {
        Mixpanel.mainInstance().track(event: event, properties: properties)
    }
    
    private func mergeDictionaries(_ dict1: [String: MixpanelType], _ dict2: [String: MixpanelType]) -> [String: MixpanelType] {
        return dict1.merging(dict2){(_, second) in second}
    }
}
