//
//  LoginViewController.swift
//  ios
//
//  Created by Lennie Stockman on 07/08/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func performLogin(_ sender: UIButton) {
        loginUser()
        UserDefaults.standard.setIsLoggedIn(value: true)
        UserDefaults.standard.synchronize()
        self.dismiss(animated: true, completion: nil)
    }
    
    func loginUser(){
        var request = URLRequest(url: URL(string: "https://givtapidebug.azurewebsites.net/oauth2/token")!)
        request.httpMethod = "POST"
        let postString = "grant_type=password&userName=debug@nfcollect.com&password=Test123"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            do
            {
                let parsedData = try JSONSerialization.jsonObject(with: data) as! [String:Any]
                let currentData = parsedData
                print(parsedData["access_token"]!)
            } catch let error as NSError {
                print(error)
            }
            
            
        }
        task.resume()
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
