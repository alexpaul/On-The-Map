//
//  BrowseLinksViewController.swift
//  On The Map
//
//  Created by Alex Paul on 8/13/15.
//  Copyright (c) 2015 Alex Paul. All rights reserved.
//

import UIKit

class BrowseLinksViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var urlTextField: UITextField!
    
    var urlString: String?
    var selectedLink: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.urlTextField.text = "http://www."
    }
    
    // MARK: IBActions 
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UITextField Delegate Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.urlString = textField.text
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
                
        let url = NSURL(string: self.urlString!)
        let request = NSURLRequest(URL: url!)
        self.webView.loadRequest(request)
    }
}
