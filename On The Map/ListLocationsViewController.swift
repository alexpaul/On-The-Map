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
    
    @IBOutlet weak var tableView: UITableView!
    
    
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
        
        let delay = 4.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        // Clear Student Locations
        OnTheMapClient.sharedInstance().studentLocations.removeAll(keepCapacity: false)
        
        dispatch_after(time, dispatch_get_main_queue()) {
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        }

        
    }

}
