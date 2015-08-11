//
//  LoginViewController.swift
//  On The Map
//
//  Created by Alex Paul on 7/29/15.
//  Copyright (c) 2015 Alex Paul. All rights reserved.
//
//  Enables the user to be authenticated via Udacity or Facebook using their appropriate credentials 

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

let USERNAME = "username" // email for the Udacity Student
let PASSWORD = "password" // password

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: View Life Cycles 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and Add Facebook Login Button
        let loginButton = FBSDKLoginButton()
        let viewCenterPoint = self.view.center
        loginButton.center = CGPointMake(viewCenterPoint.x, viewCenterPoint.y + 44)
        self.view.addSubview(loginButton)
        
        // Check for existing Facebook Tokens
        // This eliminates an unnecessary app switch to Facebook if user already granted permissions
        if let accessToken = FBSDKAccessToken.currentAccessToken()?.tokenString {
            OnTheMapClient.sharedInstance().facebookAuthentication(accessToken)
        } else {
            println("No Existing Tokens")
        }
    }
    
    
    // MARK: IBActions

    @IBAction func udacityLoginButtonPressed(sender: UIButton) {
        
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

