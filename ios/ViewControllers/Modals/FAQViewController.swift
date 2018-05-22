//
//  FAQViewController.swift
//  ios
//
//  Created by Lennie Stockman on 23/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit



class FAQViewController: UIViewController, OpenedQuestionDelegate {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var closeButton: UIButton!
    var previousQuestion: FAQView?
    func didTapFAQView(sender: FAQView) {
        if previousQuestion != nil {
            if previousQuestion != sender {
                previousQuestion?.close()
            }
        }
        previousQuestion = sender
    }
    
    func didShowAnswer(sender: FAQView) {
        /* when answer is opened, we want to scroll to the top of the Question view */
        scrollView.layoutIfNeeded()
        scrollView.scrollToView(view: sender, animated: false)
    }
    
    @IBOutlet var needHelp: UILabel!
    @IBOutlet var findAnswers: UILabel!
    @IBOutlet var stack: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        needHelp.text = NSLocalizedString("NeedHelpTitle", comment: "")
        findAnswers.text = NSLocalizedString("FindAnswersToYourQuestions", comment: "")
    }
    
    private func addQuestion(q: String, a: String, v: String? = nil) {
        addSpacer()
        let item = FAQView(q: NSLocalizedString(q, comment: ""), a: NSLocalizedString(a, comment: ""), v: v)
        item.delegate = self
        item.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(item)
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func addSpacer() {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.backgroundColor = #colorLiteral(red: 0.2509803922, green: 0.231372549, blue: 0.4, alpha: 1)
        stack.addArrangedSubview(spacer)
        spacer.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        closeButton.accessibilityLabel = NSLocalizedString("Close", comment: "")
        UIApplication.shared.statusBarStyle = .lightContent
        
        addSpacer()
        
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        stack.addArrangedSubview(spacer)
        spacer.heightAnchor.constraint(equalToConstant: 20.0).isActive = true

        addSpacer()
        
        for view in stack.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        addQuestion(q: "FAQvraag0", a: "FAQantwoord0")
        
        addQuestion(q: "QuestionHowDoesRegisteringWorks", a: "AnswerHowDoesRegistrationWork")
        addQuestion(q: "FAQHowDoesGivingWork", a: "AnswerHowDoesGivingWork", v: "https://player.vimeo.com/video/191948294?autoplay=1&title=0&byline=0&portrait=0")
        addQuestion(q: "FAQQuestion14", a: "FAQAnswer14")
        addQuestion(q: "FAQHowDoesManualGivingWork", a: "AnswerHowDoesManualGivingWork")
        addQuestion(q: "FAQvraag3", a: "FAQantwoord3")
        addQuestion(q: "FAQvraag9", a: "FAQantwoord9", v: "https://player.vimeo.com/video/205383308?autoplay=1&title=0&byline=0&portrait=0")
        addQuestion(q: "FAQQuestion12", a: "FAQAnswer12")
        addQuestion(q: "FAQQuestion11", a: "FAQAnswer11")
        addQuestion(q: "FAQvraag8", a: "FAQantwoord8")
        addQuestion(q: "FAQvraag1", a: "FAQantwoord1")
        addQuestion(q: "FAQvraag2", a: "FAQantwoord2")
        addQuestion(q: "FAQvraag4", a: "FAQantwoord4")
 
        addQuestion(q: "FAQvraag5", a: "FAQantwoord5")
        addQuestion(q: "FAQVraag16", a: "FAQAntwoord16") // annuleren van giften
        addQuestion(q: "FAQvraag6", a: "FAQantwoord6")
        addQuestion(q: "FAQvraag7", a: "FAQantwoord7")
        addQuestion(q: "FAQWhyBluetoothEnabledQ", a: "FAQWhyBluetoothEnabledA")
        addQuestion(q: "QuestionWhyAreMyDataStored", a: "AnswerWhyAreMyDataStored")
        addQuestion(q: "FAQvraag15", a: "FAQantwoord15")
        addQuestion(q: "FAQvraag17", a: "FAQantwoord17")
 
        addQuestion(q: "TermsTitle", a: "TermsText")
        addQuestion(q: "PrivacyTitle", a: "PolicyText")
 
        
        addSpacer()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
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

protocol OpenedQuestionDelegate: class {
    func didTapFAQView(sender: FAQView)
    func didShowAnswer(sender: FAQView)
}
