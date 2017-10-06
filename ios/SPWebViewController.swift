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

    var url: String!
    var webView: WKWebView!
    @IBOutlet var placeholder: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
        
        let url = URL(string: self.url)
        let request = URLRequest(url: url!)
        SVProgressHUD.show()
    
        
        // init and load request in webview.
        webView = WKWebView(frame: self.view.frame)
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
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("page fully loaded")
        if webView.url?.absoluteString == "https://givtapidebug.azurewebsites.net/" {
            webView.isHidden = true
            LoginManager.shared.finishMandateSigning(completionHandler: { (success) in
                if success {
                    DispatchQueue.main.async {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FinalRegistrationViewController") as! FinalRegistrationViewController
                        self.show(vc, sender: nil)
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: NSLocalizedString("NotificationTitle", comment: ""), message: NSLocalizedString("MandateSigingFailed", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                            self.dismiss(animated: true, completion: nil)
                            }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
            
        }
        SVProgressHUD.dismiss()
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
