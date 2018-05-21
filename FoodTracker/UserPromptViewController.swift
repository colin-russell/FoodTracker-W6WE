//
//  UserPromptViewController.swift
//  FoodTracker
//
//  Created by Colin on 2018-05-21.
//  Copyright © 2018 Colin Russell. All rights reserved.
//

import UIKit

class UserPromptViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    let signupRequester = NetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


    //MARK: Actions
    @IBAction func signupButtonTapped(_ sender: UIButton) {
        //let username = usernameField.text
        guard let username = usernameField.text else {
            print("Empty a username")
            return
        }
        guard let password = passwordField.text else {
            print("Empty password")
            return
        }
        
        if UserDefaults.standard.value(forKeyPath: username) == nil{
            UserDefaults.standard.set(username, forKey: "username")
            UserDefaults.standard.set(password, forKey: "password")
            let signupData = signupRequester.sendRequest(username: username, password: password)
            //let json = try? JSONSerialization.jsonObject(with: signupData)
            // get token here
            print(signupData?.base64EncodedString())
            UserDefaults.standard.set("", forKey: "token")
            
            print("User account created for username: \(username) and password \(password)")
        } else {
            print("User account already exists!")
        }
    }
    
    


}
