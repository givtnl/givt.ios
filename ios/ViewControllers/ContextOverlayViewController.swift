//
//  ContextOverlayViewController.swift
//  ios
//
//  Created by Lennie Stockman on 6/04/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit

class ContextOverlayViewController: UIViewController {

    @IBOutlet var yesPlease: CustomButton!
    @IBOutlet var noThanks: CustomButton!
    @IBOutlet var subLabel: UILabel!
    @IBOutlet var topLabel: UILabel!
    @IBOutlet var contextImage: UIImageView!
    @IBOutlet var contextTitle: UILabel!
    var selectedContext: Context!
    
    private var navigationManager = NavigationManager.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nope(_ sender: Any) {
        navigationManager.showContextSituation(self.navigationController!, tempContext: selectedContext.type)
    }
    
    @IBAction func yep(_ sender: Any) {
        navigationManager.setContextType(type: selectedContext.type)
        navigationManager.showContextSituation(self.navigationController!)
    }
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
