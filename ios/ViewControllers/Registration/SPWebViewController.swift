//
//  SPWebViewController.swift
//  ios
//
//  Created by Lennie Stockman on 28/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import WebKit
import SVProgressHUD


class SPWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate  {
    @IBOutlet var backButton: UIBarButtonItem!
    private var log = LogService.shared
    var url: String!
    private var webView: WKWebView!
    @IBOutlet weak var placeholder: UIView!
    @IBOutlet weak var navBar: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let url = URL(string: self.url)
        let request = URLRequest(url: url!)
        
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);";
        
        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let userContentController: WKUserContentController = WKUserContentController()
        let conf = WKWebViewConfiguration()
        conf.userContentController = userContentController
        userContentController.addUserScript(script)
        
        // init and load request in webview.
        webView = WKWebView(frame: self.view.frame, configuration: conf)
        webView.contentMode = .scaleAspectFit
        webView.isMultipleTouchEnabled = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.load(request)
        self.placeholder.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.bottomAnchor.constraint(equalTo: self.placeholder.bottomAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: self.placeholder.trailingAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: self.placeholder.leadingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: self.placeholder.topAnchor).isActive = true
        webView.scrollView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("page fully loaded")
        SVProgressHUD.show()
        let possibleUrls = [".azurewebsites.net","api2.nfcollect.com","api.givtapp.net"]
        
        guard let webViewUrl = webView.url else { return }
        
        let filteredStrings = possibleUrls.filter({(item: String) -> Bool in
            return webViewUrl.absoluteString.lowercased().range(of: item) != nil ? true : false
        })
        
        if filteredStrings.count > 0  {
            SVProgressHUD.show(withStatus: NSLocalizedString("AwaitingMandateStatus", comment: ""))
            webView.isHidden = true
            LoginManager.shared.finishMandateSigning(completionHandler: { (success) in
                if success {
                    self.log.info(message: "Finished mandate signing")
                    DispatchQueue.main.async {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FinalRegistrationViewController") as! FinalRegistrationViewController
                        self.show(vc, sender: nil)
                    }
                    
                } else {
                    self.log.warning(message: "Could not finish mandate signing")
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: NSLocalizedString("RequestFailed", comment: ""), message: NSLocalizedString("MandateSigingFailed", comment: ""), preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                            self.navigationController?.dismiss(animated: false, completion: nil)
                            NavigationManager.shared.loadMainPage()
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
            
        }
        
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
                let bbi = UIBarButtonItem(title: NSLocalizedString("Close", comment: ""), style: .done, target: self, action: #selector(previousPage))
                backButton.isEnabled = false
                backButton.image = UIImage()
                self.navBar.setRightBarButton(bbi, animated: true)
            }
            return nil
        }
        return nil
    }
    
    @objc func previousPage() {
        webView.goBack()
        self.navBar.setRightBarButtonItems([], animated: true)
        self.backButton.isEnabled = true
        self.backButton.image = #imageLiteral(resourceName: "backbtn")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        SVProgressHUD.dismiss()
    }
    
    deinit {
        self.webView.scrollView.delegate = nil
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
