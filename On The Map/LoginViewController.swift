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
    
    var facebookLoginButton: FBSDKLoginButton!
    var facebookLoginSuccess = false
    
    // MARK: View Life Cycles
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: may have to done explicity on the Main Thread
        self.usernameTextField.text = ""
        self.passwordTextField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and Add Facebook Login Button
        self.facebookLoginButton = FBSDKLoginButton()
        let viewCenterPoint = self.view.center
        self.facebookLoginButton.center = CGPointMake(viewCenterPoint.x, viewCenterPoint.y + 44)
        self.view.addSubview(self.facebookLoginButton)
        
        
//        // Check for existing Facebook Tokens
//        // This eliminates an unnecessary app switch to Facebook if user already granted permissions
//        if let accessToken = FBSDKAccessToken.currentAccessToken()?.tokenString {
//            // Authenticate Facebook User
//            OnTheMapClient.sharedInstance().facebookAuthentication(accessToken) { (success, result, error) in
//                if success {
//                    self.facebookLoginSuccess = true
//                }else {
//                    self.facebookLoginSuccess = false
//                    self.loginAlertMessage(error)
//                }
//            }
//        } else {
//            println("Error locating token")
//        }
//        
//        self.facebookLoginButton.addTarget(self, action: "facebookLoginButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    // MARK: IBActions

    @IBAction func udacityLoginButtonPressed(sender: UIButton) {
        
        OnTheMapClient.sharedInstance().authenticateUser(username: self.usernameTextField.text, password: self.passwordTextField.text) { (success, result, error) in
            
            if success {
                self.completeLogin()
            }else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.loginAlertMessage(error)
                }
            }
        }
    }
    
    @IBAction func signupButtonPressed(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }
    
    // MARK: Helper Methods
    
    func completeLogin() {
        
        // Download the Students Locations from Parse
        OnTheMapClient.sharedInstance().getStudentLocations { (error) in
            if error != nil {
                // TODO: Add an Alert to inform the user that Student Locations failed to Download
                println("Error downloading student locations: \(error)")
            }
        }
        
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
    
    func facebookLoginButtonPressed() {
        
        if self.facebookLoginButton.selected { // "log out"
            self.completeLogin()
        }else { // "log in with facebook"

        }
    }
    


}

