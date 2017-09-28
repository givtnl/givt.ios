//
//  SPWebViewController.swift
//  ios
//
//  Created by Lennie Stockman on 28/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import WebKit

class SPWebViewController: UIViewController, WKNavigationDelegate  {

    var webView: WKWebView!
    @IBOutlet var placeholder: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let myBlog = "https://google.be/"
        let url = URL(string: myBlog)
        let request = URLRequest(url: url!)
        
        // init and load request in webview.
        webView = WKWebView(frame: self.view.frame)
        webView.navigationDelegate = self
        webView.load(request)
        self.placeholder.addSubview(webView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
