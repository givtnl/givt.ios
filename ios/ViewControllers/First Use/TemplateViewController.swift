//
//  TemplateViewController.swift
//  ios
//
//  Created by Lennie Stockman on 14/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit

class TemplateViewController: UIViewController {
    
    var sTitle: String!
    var subtitle: String!
    var uImage: UIImage!
    
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var subtitleText: UILabel!
    @IBOutlet var titleText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        titleText.text = sTitle
        subtitleText.text = subtitle
        image.image = uImage
        // Do any additional setup after loading the view.
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
