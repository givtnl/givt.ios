//
//  ExternalSuggestionViewControllerExtension.swift
//  ios
//
//  Created by Mike Pattyn on 17/02/2022.
//  Copyright © 2022 Givt. All rights reserved.
//

import Foundation
import UIKit

extension ExternalSuggestionViewController {
    func setupMessageBox() {
        let externalSuggestion = ExternalSuggestionView(frame: CGRect.zero)
        externalSuggestion.label.text = "Nicorette {0}"
        self.view.addSubview(externalSuggestion)
        externalSuggestion.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        externalSuggestion.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        externalSuggestion.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        externalSuggestion.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        externalSuggestion.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        var action = #selector(self.giveAction)
        if externalIntegrationObject!.entryKind == .QRCode && !qrCode!.Active {
            action = #selector(self.giveActionNameSpace)
        }
        externalSuggestion.button.addTarget(self, action: action, for: UIControl.Event.touchUpInside)
        externalSuggestion.button.setTitle(NSLocalizedString("YesPlease", comment: ""), for: UIControl.State.normal)
        externalSuggestion.cancelButton.addTarget(self, action: #selector(self.cancel), for: UIControl.Event.touchUpInside)
        externalSuggestion.cancelButton.isUserInteractionEnabled = true
        externalSuggestion.label.attributedText = StringHelper.getAttributedTextWithBoldCollectGroupName(getMessageForExternalSuggestionKind(externalIntegrationObject!.entryKind), self.collectGroupDetailModel!.OrgName)
        externalSuggestion.image.image = externalIntegrationObject!.logo
    }
    @objc func giveAction() {
        giveManually(antennaID: self.externalIntegrationObject!.mediumId)
    }
    
    @objc func giveActionNameSpace() {
        giveManually(antennaID: self.collectGroupDetailModel!.EddyNameSpace)
    }
    
    @objc func cancel(sender: UIButton) {
        GivtManager.shared.externalIntegration = nil
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: {
                self.closeAction()
            })
        }
    }
    fileprivate func getMessageForExternalSuggestionKind(_ externalSuggestionKind: ExternalAppIntegration.ExternalSuggestionKind) -> String {
        switch externalSuggestionKind {
            case .Normal:
                return "GiveOutOfApp".localized.replace("{0}", with: self.collectGroupDetailModel!.OrgName)
            case .QRCode:
                if self.qrCode!.Active {
                    return "QRScannedOutOfApp".localized.replace("{0}", with: self.collectGroupDetailModel!.OrgName)
                } else {
                    return "InvalidQRcodeMessage".localized.replace("{0}", with: self.collectGroupDetailModel!.OrgName)
                }
            default:
                return "ExternalSuggestionLabel".localized.replace("{0}", with: self.collectGroupDetailModel!.OrgName)
        }
    }
    
}
