//
//  AboutViewController.swift
//  ios
//
//  Created by Lennie Stockman on 15/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit
import SVProgressHUD

class AboutViewController: UIViewController, UITextViewDelegate {

    public var prefilledText: String?
    private var log = LogService.shared
    @IBOutlet var titleText: UILabel!
    @IBOutlet var versionNumber: UILabel!
    @IBOutlet var giveFeedback: UILabel!
    @IBOutlet var btnSend: UIButton!
    @IBOutlet var textView: CustomUITextView!
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goBack.accessibilityLabel = NSLocalizedString("Back", comment: "")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: nil)
        // Do any additional setup after loading the view.
        textView.placeholder = NSLocalizedString("TypeMessage", comment: "")
        btnSend.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
        giveFeedback.text = NSLocalizedString("FeedbackTitle", comment: "")
        
        let country = try? Mediater.shared.send(request: GetCountryQuery())
        
        if AppServices.isCountryFromSimGB() || UserDefaults.standard.accountType == .bacs {
            titleText.text = NSLocalizedString("InformationAboutUsGB", comment: "")
        } else if country == "US" {
            titleText.text = NSLocalizedString("InformationAboutUsUS", comment: "")
        } else {
            titleText.text = NSLocalizedString("InformationAboutUs", comment: "")
        }
        versionNumber.text = NSLocalizedString("AppVersion", comment: "") + AppConstants.AppVersionNumber
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        // prevents the scroll view from swallowing up the touch event of child buttons
        tapGesture.cancelsTouchesInView = true
        scrollView.addGestureRecognizer(tapGesture)
        
        btnSend.setBackgroundColor(color: UIColor.init(rgb: 0xE3E2E7), forState: UIControl.State.disabled)
        btnSend.isEnabled = false
        
        if let prefilled = prefilledText {
            textView.tag = 1
            textView.text = prefilled
            textView.placeholder = prefilled
            textView.becomeFirstResponder()
            textView.selectedRange = NSMakeRange(prefilled.count, 0)
        }
    }
    
    @objc private func textDidChange(notification: Notification) {
        if let tv = notification.object as? CustomUITextView {
            let text = tv.text.trimmingCharacters(in: .whitespacesAndNewlines)
            let placeholder = tv.placeholder?.trimmingCharacters(in: .whitespacesAndNewlines)
            btnSend.isEnabled = !text.isEmpty && text != placeholder
        }
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
        if textView.tag != 1 {
            justifyScrollViewContent()
        } else {
            justifyScrollViewContentWhenUseFirstResponder(keyboardHeight: keyboardFrame.size.height)
        }
    }
    
    func justifyScrollViewContent() {
        var offset = scrollView.contentOffset
        offset.y = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.size.height
        scrollView.setContentOffset(offset, animated: true)
    }
    
    func justifyScrollViewContentWhenUseFirstResponder(keyboardHeight: CGFloat) {
        var offset = scrollView.contentOffset
        offset.y = keyboardHeight
        scrollView.setContentOffset(offset, animated: true)
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet var goBack: UIBarButtonItem!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.endEditing()
    }
    
    func send() {
        endEditing()
        textView.text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !AppServices.shared.isServerReachable {
            let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("ConnectionError", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            }))
            self.present(alert, animated: true, completion:  {})
            return
        }

        let br = "<br/>"
        let appVersion = "App version: " + AppConstants.AppVersionNumber
        let device = "Device: " + UIDevice.current.modelName
        let os = "Operating system: " + UIDevice.current.systemName + " " + UIDevice.current.systemVersion
        let appLang = "App language: "  + Locale.preferredLanguages[0]
        let email = "Email: " + UserDefaults.standard.userExt!.email
        var message = textView.text.replacingOccurrences(of: "\n", with: br)
        let footer = email + br + appVersion + br + os + br + device + br + appLang
        
        message += br + br + footer
        
        SVProgressHUD.show()
        LoginManager.shared.sendSupport(text: message) { (status) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            if status {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: NSLocalizedString("Success", comment: ""), message: NSLocalizedString("FeedbackMailSent", comment: ""), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: {})
                    }))
                    self.present(alert, animated: true, completion:  {})
                }
            } else {
                self.log.warning(message: "Could not send message to support")
                let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("ConnectionError", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    self.dismiss(animated: true, completion: {})
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("TryAgain", comment: ""), style: .default, handler: { (action) in
                    self.send()
                }))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
            print(status)
        }
    }
    @IBAction func send(_ sender: Any) {
        send()
        
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
