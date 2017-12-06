//
//  FAQViewController.swift
//  ios
//
//  Created by Lennie Stockman on 23/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit

class FAQViewController: UIViewController {
    
    @IBOutlet var needHelp: UILabel!
    @IBOutlet var findAnswers: UILabel!
    @IBOutlet var stack: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        needHelp.text = NSLocalizedString("NeedHelpTitle", comment: "")
        findAnswers.text = NSLocalizedString("FindAnswersToYourQuestions", comment: "")
        
        addQuestion(q: "FAQvraag0", a: "FAQantwoord0")
        addQuestion(q: "QuestionHowDoesRegisteringWorks", a: "AnswerHowDoesRegistrationWork", v: "https://player.vimeo.com/video/205383298?autoplay=1&title=0&byline=0&portrait=1")
        addQuestion(q: "FAQHowDoesGivingWork", a: "AnswerHowDoesGivingWork", v: "https://player.vimeo.com/video/191948294?autoplay=1&title=0&byline=0&portrait=0")
        addQuestion(q: "FAQQuestion14", a: "FAQAnswer14", v: "https://player.vimeo.com/video/214000434?autoplay=1&title=0&byline=0&portrait=0")
        addQuestion(q: "FAQHowDoesManualGivingWork", a: "AnswerHowDoesManualGivingWork", v: "https://player.vimeo.com/video/191943978?autoplay=1&title=0&byline=0&portrait=0")
        addQuestion(q: "FAQvraag3", a: "FAQantwoord3", v: "https://player.vimeo.com/video/205383298?autoplay=1&title=0&byline=0&portrait=0")
        addQuestion(q: "FAQvraag9", a: "FAQantwoord9", v: "https://player.vimeo.com/video/205383308?autoplay=1&title=0&byline=0&portrait=0")
        addQuestion(q: "FAQQuestion12", a: "FAQAnswer12")
        addQuestion(q: "FAQQuestion11", a: "FAQAnswer11", v: "https://player.vimeo.com/video/207768598?autoplay=1&title=0&byline=0&portrait=0")
        addQuestion(q: "FAQvraag8", a: "FAQantwoord8", v: "https://player.vimeo.com/video/205383284?autoplay=1&title=0&byline=0&portrait=0")
        addQuestion(q: "FAQvraag1", a: "FAQantwoord1")
        addQuestion(q: "FAQvraag2", a: "FAQantwoord2")
        addQuestion(q: "FAQvraag4", a: "FAQantwoord4")
        addQuestion(q: "FAQvraag5", a: "FAQantwoord5")
        addQuestion(q: "FAQvraag6", a: "FAQantwoord6")
        addQuestion(q: "FAQvraag7", a: "FAQantwoord7")
        addQuestion(q: "FAQWhyBluetoothEnabledQ", a: "FAQWhyBluetoothEnabledA")
        addQuestion(q: "QuestionWhyAreMyDataStored", a: "PolicyText")
        addQuestion(q: "FAQvraag15", a: "FAQantwoord15")
        addQuestion(q: "TermsTitle", a: "TermsText")
        
        addSpacer()
        // Do any additional setup after loading the view.
    }
    
    private func addQuestion(q: String, a: String, v: String? = nil) {
        addSpacer()
        let item = FAQView(q: NSLocalizedString(q, comment: ""), a: NSLocalizedString(a, comment: ""), v: v)
        item.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(item)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
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
