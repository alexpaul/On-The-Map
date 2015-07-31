//
//  LoginViewController.swift
//  On The Map
//
//  Created by Alex Paul on 7/29/15.
//  Copyright (c) 2015 Alex Paul. All rights reserved.
//

import UIKit

let USERNAME = "username" // email for the Udacity Student
let PASSWORD = "password" // password

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func loginButtonPressed(sender: UIButton) {
        
        OnTheMapClient.sharedInstance().authenticateUser(username: usernameTextField.text, password: passwordTextField.text)
        
    }


}

