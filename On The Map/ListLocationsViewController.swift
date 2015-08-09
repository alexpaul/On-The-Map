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
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentLocation = OnTheMapClient.sharedInstance().studentLocations[indexPath.row]
        if let mediaURL = studentLocation.mediaURL {
            UIApplication.sharedApplication().openURL(NSURL(string: mediaURL)!)
        }
    }

}
