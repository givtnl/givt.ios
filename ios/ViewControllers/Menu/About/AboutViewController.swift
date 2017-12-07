//
//  AboutViewController.swift
//  ios
//
//  Created by Lennie Stockman on 15/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit
import SVProgressHUD

class AboutViewController: UIViewController {

    private var log = LogService.shared
    @IBOutlet var titleText: UILabel!
    @IBOutlet var versionNumber: UILabel!
    @IBOutlet var giveFeedback: UILabel!
    @IBOutlet var btnSend: UIButton!
    @IBOutlet var textView: CustomUITextView!
    @IBOutlet var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        // Do any additional setup after loading the view.
        textView.placeholder = NSLocalizedString("TypeMessage", comment: "")
        btnSend.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
        giveFeedback.text = NSLocalizedString("FeedbackTitle", comment: "")
        titleText.text = NSLocalizedString("InformationAboutUs", comment: "")
        versionNumber.text = NSLocalizedString("AppVersion", comment: "") + AppConstants.AppVersionNumber
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
        
        justifyScrollViewContent()
    }
    
    func justifyScrollViewContent() {
        var offset = scrollView.contentOffset
        offset.y = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.size.height
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
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
    }
    
    func send() {
        textView.text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if textView.text.isEmpty() || textView.text == textView.placeholder {
            let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("NoMessage", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            }))
            self.present(alert, animated: true, completion:  {})
            return
        }
        
        if !AppServices.shared.connectedToNetwork() {
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
        let email = "Email: " + UserDefaults.standard.userExt.email
        let name = UserDefaults.standard.tempUser ? "Temporary account" : UserDefaults.standard.userExt.firstName + " " + UserDefaults.standard.userExt.lastName
        var message = textView.text.replacingOccurrences(of: "\n", with: br)
        let footer = name + br + email + br + appVersion + br + os + br + device + br + appLang
        
        message += br + br + footer
        
        SVProgressHUD.show()
        LoginManager.shared.sendSupport(text: message) { (status) in
            if status {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: NSLocalizedString("PincodeSuccessfullTitle", comment: ""), message: NSLocalizedString("FeedbackMailSent", comment: ""), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: {})
                    }))
                    self.present(alert, animated: true, completion:  {})
                }
            } else {
                self.log.warning(message: "Could not send message to support")
                let alert = UIAlertController(title: NSLocalizedString("NotificationTitle", comment: ""), message: NSLocalizedString("SomethingWentWrong", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    self.dismiss(animated: true, completion: {})
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("TryAgain", comment: ""), style: .default, handler: { (action) in
                    self.send()
                }))
                
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
