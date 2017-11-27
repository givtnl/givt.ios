//
//  FAQView.swift
//  ios
//
//  Created by Lennie Stockman on 23/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class FAQView: UIView, WKNavigationDelegate, WKUIDelegate {
    var answer: UILabel!
    var question: UILabel!
    
    var questionWrapper: UIView!
    var answerWrapper: UIView!
    var videoWrapper: WKWebView?
    var videoUrl: String?
    var loader: UIActivityIndicatorView?
    //-----------------------------------------------------------------------------------------------------
    //Constructors, Initializers, and UIView lifecycle
    //-----------------------------------------------------------------------------------------------------
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    convenience init(q: String, a: String, v: String? = nil) {
        self.init(frame: .zero)
        didLoad(q: q, a: a, v: v)
    }
    
    func didLoad(q: String, a: String, v: String?) {
        self.videoUrl = v
        
        self.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(openAnswer))
        
        questionWrapper = UIView()
        questionWrapper.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        questionWrapper.translatesAutoresizingMaskIntoConstraints = false
        questionWrapper.isUserInteractionEnabled = true
        questionWrapper.addGestureRecognizer(tap)
        self.addSubview(questionWrapper)
        
        answerWrapper = UIView()
        answerWrapper.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        answerWrapper.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(answerWrapper)
        
        questionWrapper.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        questionWrapper.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        questionWrapper.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        
        answerWrapper.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        answerWrapper.topAnchor.constraint(equalTo: questionWrapper.bottomAnchor, constant: 0).isActive = true
        answerWrapper.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        answerWrapper.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        question = UILabel()
        question.textColor = .white
        question.font = UIFont(name: "Avenir-Heavy", size: 16.0)
        question.text = q
        question.numberOfLines = 0
        question.translatesAutoresizingMaskIntoConstraints = false
        questionWrapper.addSubview(question)
        question.leadingAnchor.constraint(equalTo: questionWrapper.leadingAnchor, constant: 20).isActive = true
        question.topAnchor.constraint(equalTo: questionWrapper.topAnchor, constant: 20).isActive = true
        question.trailingAnchor.constraint(equalTo: questionWrapper.trailingAnchor, constant: -20).isActive = true
        question.bottomAnchor.constraint(equalTo: questionWrapper.bottomAnchor, constant: -20).isActive = true
        
        answer = UILabel()
        answer.textColor = .white
        answer.font = UIFont(name: "Avenir-Roman", size: 16.0)
        answer.text = a
        answer.numberOfLines = 0
        answer.translatesAutoresizingMaskIntoConstraints = false
        
        
        
    }
    
    @objc func openAnswer() {
        if let view = answer.superview {
            answer.removeFromSuperview()
            videoWrapper?.removeFromSuperview()
            
            self.layoutIfNeeded()
        } else {
            answerWrapper.addSubview(answer)
            answer.leadingAnchor.constraint(equalTo: answerWrapper.leadingAnchor, constant: 20).isActive = true
            answer.topAnchor.constraint(equalTo: answerWrapper.topAnchor, constant: 0).isActive = true
            answer.trailingAnchor.constraint(equalTo: answerWrapper.trailingAnchor, constant: -20).isActive = true
            
            if let v = videoUrl {
                let request = URLRequest(url: URL(string: v)!)
                videoWrapper = WKWebView()
                videoWrapper?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                videoWrapper?.load(request)
                videoWrapper?.navigationDelegate = self
                videoWrapper?.uiDelegate = self
                videoWrapper?.translatesAutoresizingMaskIntoConstraints = false
                self.answerWrapper.addSubview(videoWrapper!)
                
                videoWrapper?.leadingAnchor.constraint(equalTo: answerWrapper.leadingAnchor).isActive = true
                videoWrapper?.topAnchor.constraint(equalTo: answer.bottomAnchor, constant: 20).isActive = true
                videoWrapper?.trailingAnchor.constraint(equalTo: answerWrapper.trailingAnchor).isActive = true
                videoWrapper?.bottomAnchor.constraint(equalTo: answerWrapper.bottomAnchor, constant: -20).isActive = true
                videoWrapper?.heightAnchor.constraint(equalToConstant: 210).isActive = true
                
                insertCSSString(into: videoWrapper!)
                
            } else {
                answer.bottomAnchor.constraint(equalTo: answerWrapper.bottomAnchor, constant: -20).isActive = true
            }
            
            
            self.layoutIfNeeded()
            
            
        }
        
        
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        insertCSSString(into: webView) // 1
        // OR
        //insertContentsOfCSSFile(into: webView) // 2
    }
    
    func insertCSSString(into webView: WKWebView) {
        let cssString = "body { background-color:#2E2957; } .vp-player-layout { left: 0 !important, right: 0 !important;}"
        let jsString = "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);document.getElementsByClassName('js-playerLayout')[0].style = 'left:0;right:0;'"
        webView.evaluateJavaScript(jsString, completionHandler: nil)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        //Custom manually positioning layout goes here (auto-layout pass has already run first pass)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        //Disable this if you are adding constraints manually
        //or you're going to have a 'bad time'
        //self.translatesAutoresizingMaskIntoConstraints = false
        
        //Add custom constraint code here
    }
}
