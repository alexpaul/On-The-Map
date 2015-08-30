//
//  ListLocationsViewController.swift
//  On The Map
//
//  Created by Alex Paul on 7/30/15.
//  Copyright (c) 2015 Alex Paul. All rights reserved.
//
//  Uses a Table View to list Student Locations 

import UIKit



class ListLocationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: View Life Cycle 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create two (2) Button Bar Items on the Right Side of the Navigation Bar
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshButtonPressed")
        let postButton = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "postButtonPressed")
        self.navigationController?.navigationBar.topItem?.rightBarButtonItems = [refreshButton, postButton]
    }
    
    // MARK: UITableViewDataSource Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OnTheMapClient.sharedInstance().studentLocations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentLocationCell") as! UITableViewCell
        
        let studentLocation = OnTheMapClient.sharedInstance().studentLocations[indexPath.row]
        let firstName = studentLocation.firstName!
        let lastName = studentLocation.lastName!
        
        cell.textLabel?.text = firstName + " " + lastName
        if let mediaURL = studentLocation.mediaURL {
            cell.detailTextLabel?.text = mediaURL
            cell.imageView?.image = UIImage(named: "pin")
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate Methods
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentLocation = OnTheMapClient.sharedInstance().studentLocations[indexPath.row]
        if let mediaURL = studentLocation.mediaURL {
            UIApplication.sharedApplication().openURL(NSURL(string: mediaURL)!)
        }
    }
    
    // MARK: IBActions 
    
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        OnTheMapClient.sharedInstance().logoutUdacitySession()
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Helper Methods
    
    func postButtonPressed() {
        let infoPostVC = self.storyboard?.instantiateViewControllerWithIdentifier("InformationPostingVC") as! InformationPostingVC
        self.navigationController?.presentViewController(infoPostVC, animated: true, completion: nil)
    }
    
    func refreshButtonPressed() {
        self.activityIndicator.startAnimating()
        
        // Fetch Data on a Background Thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            OnTheMapClient.sharedInstance().getStudentLocations({ (success, result, error) -> Void in
                if error != nil {
                    // TODO: Add an Alert to inform the user that Student Locations failed to Download
                    println("Error downloading student locations: \(error)")
                }
            })
            
            // Main Thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.activityIndicator.stopAnimating();
            })
        })
    }

}
