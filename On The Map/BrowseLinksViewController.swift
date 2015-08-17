//
//  BrowseLinksViewController.swift
//  On The Map
//
//  Created by Alex Paul on 8/13/15.
//  Copyright (c) 2015 Alex Paul. All rights reserved.
//

import UIKit

class BrowseLinksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var links = [String?]()
    var selectedLink: String? = nil

    // MARK: UITableViewDelegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println(self.links)
        return self.links.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LinkCell") as! UITableViewCell
        
        if let link = self.links[indexPath.row] {
            cell.textLabel?.text = link
        }else {
            cell.textLabel?.text = "No URL Found"
        }
        
        return cell
    }
    
    // MARK: UITableViewDataSource Methods
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("didSelectRowAtIndexPath")
        self.selectedLink = self.links[indexPath.row]
        if let link = self.selectedLink {
            println("link in didSelectRowAtIndexPath: \(link)")
        }
    }
    
    // MARK: IBActions 
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        
    }
    

}
