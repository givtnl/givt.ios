//
//  USSecondRegistrationViewControllerWebViewExtension.swift
//  ios
//
//  Created by Maarten Vergouwe on 18/01/2022.
//  Copyright © 2022 Givt. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SVProgressHUD

extension USRegistrationViewController : WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: String] else { return }
        if body.first?.key == "event" && body.first?.value == "iFrameLoaded" {
            self.hideLoader()
        } else if body.first?.key == "error" {
            self.reloadWebView(userContentController)
            self.showCreditCardError()
            }
        } else if body.first?.key == "token" {
            handleTokenizeFinished(token: body.first!.value)
        } else {
            print(body)
        }
    }
    func showCreditCardError() {
        let alert = UIAlertController(title: "Error", message: "Please check your credit card credentials", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        SVProgressHUD.dismiss(withDelay: 0) { self.present(alert, animated: true) }
    }
    func reloadWebView(_ userContentController: WKUserContentController) {
        if #available(iOS 14.0, *) {
            userContentController.removeAllScriptMessageHandlers()
        } else {
            userContentController.removeScriptMessageHandler(forName: "registrationMessageHandler")
        }
        self.loadWebview()
    }
    func loadWebview() {
        creditCardWebView.scrollView.contentInset = UIEdgeInsets(top: -8, left: -9, bottom: 0, right: 0)
        creditCardWebView.scrollView.isScrollEnabled = false
        creditCardWebView.configuration.userContentController.add(self, name: "registrationMessageHandler")
        if let url = Bundle.main.url(forResource: "wepay", withExtension: "html") {
            creditCardWebView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }
    
    func tokenize() {
        let script = """
            wkVars.messageHandler.postMessage({'event': 'Start tokenizing'})
            const tokenize = wkVars.creditCard.tokenize()
              .then(function(response) {
                wkVars.messageHandler.postMessage({'token': response.id});
              })
              .catch(function(error) {
                let key = error[0].target[0];
                wkVars.creditCard.setFocus(key);
                wkVars.messageHandler.postMessage({'error': JSON.stringify(error)});
              });
        """
        
        creditCardWebView.evaluateJavaScript(script) { _,_ in }
    }
}
