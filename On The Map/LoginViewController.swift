//
//  LoginViewController.swift
//  On The Map
//
//  Created by Alex Paul on 7/29/15.
//  Copyright (c) 2015 Alex Paul. All rights reserved.
//
//  Enables the user to be authenticated via Udacity or Facebook using their appropriate credentials 

import UIKit

let USERNAME = "username" // email for the Udacity Student
let PASSWORD = "password" // password

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: IBActions

    @IBAction func loginButtonPressed(sender: UIButton) {
        
        OnTheMapClient.sharedInstance().authenticateUser(username: self.usernameTextField.text, password: self.passwordTextField.text) { (success, result, error) in
            
            if success {
                self.completeLogin()
            }else {
                self.loginAlertMessage(error)
            }
        }
        
    }
    
    @IBAction func signupButtonPressed(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }
    
    // MARK: Helper Methods
    
    func completeLogin() {
        
        // Get the Students Locations from the Parse API
        OnTheMapClient.sharedInstance().getStudentLocations()
        
        dispatch_async(dispatch_get_main_queue()) {
            let tabBarController = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
            self.presentViewController(tabBarController, animated: true, completion: nil)
        }
    }
    
    func loginAlertMessage(error: String?) {
        let alertController = UIAlertController(title: "Login Alert", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(alertAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    


}

