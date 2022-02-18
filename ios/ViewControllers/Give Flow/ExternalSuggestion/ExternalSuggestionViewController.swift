//
//  ExternalSuggestionViewController.swift
//  ios
//
//  Created by Lennie Stockman on 11/07/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit
import AudioToolbox
import SafariServices

class ExternalSuggestionViewController: BaseScanViewController {
    var externalIntegrationObject: ExternalAppIntegration? = nil
    var collectGroupDetailModel: OrgBeacon? = nil
    var qrCode: QrCode? = nil
    
    var closeAction: () -> () = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        externalIntegrationObject = GivtManager.shared.externalIntegration
        
        collectGroupDetailModel = UserDefaults.standard.orgBeaconListV2?.OrgBeacons
            .first(where: { orgBeacon in orgBeacon.EddyNameSpace == externalIntegrationObject!.namespace })
        
        qrCode = collectGroupDetailModel?.QrCodes?
            .first(where: { qrCode in qrCode.MediumId == externalIntegrationObject!.mediumId })
               
        setupMessageBox()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GivtManager.shared.delegate = self
        GivtManager.shared.externalIntegration!.wasShownAlready = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GivtManager.shared.delegate = nil
    }
    
    override func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        if let _ = URL.absoluteString.index(of: "cloud.givtapp.net") {
            DispatchQueue.main.async {
                self.safariViewController?.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: .GivtAmountsShouldReset, object: self)
            }
        }
    }
}
