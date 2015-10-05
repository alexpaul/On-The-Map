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



class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // UITextFields
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // UILabels
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    
    // UIButtons
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    
    // MARK: View Life Cycles
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.usernameTextField.text = ""
        self.passwordTextField.text = ""
        
        if let token = FBSDKAccessToken.currentAccessToken()?.tokenString {
            println("token present")
        }else {
            println("no token present")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize Apperance of UI Elements
        self.customizeAppearanceForUIElements()
        
        // Check for an existing Facebook Token
        // This eliminates an unnecessary app switch to Facebook if user already granted permissions
        // Then Authenticate the User and Complete Login if Successful
        self.getCurrentTokenAndAuthenticateFacebookUser()
        
        self.facebookLoginButton.addTarget(self, action: "facebookLoginButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    // MARK: IBActions

    @IBAction func udacityLoginButtonPressed(sender: UIButton) {
        
        if usernameTextField.text == "" && passwordTextField.text == "" {
            self.missingCredentialsAlertMessage()
        } else {
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
    }
    
    @IBAction func signupButtonPressed(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }
    
    // MARK: Helper Methods
    
    func completeLogin() {
        
        // Download the Students Locations from Parse
        OnTheMapClient.sharedInstance().getStudentLocations { (success, result, error) in
            if error != nil {
                // TODO: Add an Alert to inform the user that Student Locations failed to Download
                println("Error downloading student locations: \(error)")
            }else {
                if let res = result {
                    println("result: \(result!) student locations")
                }else {
                    println("Error retrieving student locations")
                }
                
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.activityIndicator.stopAnimating()
            
            // Create and Present Tab View Controller. 
            // Map Locations VC will be the initial view
            let tabBarController = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
            self.presentViewController(tabBarController, animated: true, completion: nil)
        }
    }
    
    func getCurrentTokenAndAuthenticateFacebookUser() {
        if let accessToken = FBSDKAccessToken.currentAccessToken()?.tokenString {
            
            self.activityIndicator.startAnimating()
            
            // Authenticate Facebook User and Complete Login
            OnTheMapClient.sharedInstance().facebookAuthentication(accessToken) { (success, result, error) in
                // If there is an Access Token and Login is Successful
                // Go to Tab Bar Controller
                if success {
                    // Complete Login
                    self.completeLogin()
                    
                }else {
                    self.loginAlertMessage(error)
                }
            }
        } else {
            println("Error locating token")
        }
    }
    
    func customizeAppearanceForUIElements() {
        // UITextField
        let textFieldAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "Roboto-Regular", size: 18)!]
        self.usernameTextField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: textFieldAttributes)
        self.usernameTextField.defaultTextAttributes = textFieldAttributes
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: textFieldAttributes)
        self.passwordTextField.defaultTextAttributes = textFieldAttributes
        // UILabel
        let labelFont = UIFont(name: "Roboto-Regular", size: 18)
        self.loginLabel.textColor = UIColor.whiteColor()
        self.loginLabel.font = labelFont
        self.accountLabel.textColor = UIColor.whiteColor()
        self.accountLabel.font = labelFont
        // UIButton
        let buttonFont = UIFont(name: "Roboto-Regular", size: 16)
        self.loginButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.loginButton.titleLabel?.font = buttonFont
        self.signUpButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.signUpButton.titleLabel?.font = buttonFont
        self.facebookLoginButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.facebookLoginButton.titleLabel?.font = buttonFont
        
        // Create and Add Facebook Login Button
//        self.facebookLoginButton = FBSDKLoginButton()
//        let viewCenterPoint = self.view.center
//        self.facebookLoginButton.center = CGPointMake(viewCenterPoint.x, viewCenterPoint.y + 150)
//        self.view.addSubview(self.facebookLoginButton)        
    }
    
    // MARK: Alert Methods 
    
    func missingCredentialsAlertMessage () {
        let alertController = UIAlertController(title: "Missing Login Credentials", message: "Username and Password are Required", preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(alertAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func loginAlertMessage(error: String?) {
        let alertController = UIAlertController(title: "Login Alert", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(alertAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func facebookLoginButtonPressed() {
        
        let facebookPerrmisssions = ["public_profile", "email", "user_friends"]
        let loginManager = FBSDKLoginManager()
        
        loginManager.logInWithReadPermissions(facebookPerrmisssions, handler: { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            if error != nil {
                // Process Error
                println("Facebook Error: \(error.description)")
            }else if result.isCancelled {
                // Handle Cancellations
                println("Handle Cancellations")
            }else {
                // Logged In
                println("Logged In")

                // Get Current Token and Authenticate Facebook User
                self.getCurrentTokenAndAuthenticateFacebookUser()
            }
        })
    }
    

    // MARK: UITextFieldDelegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

