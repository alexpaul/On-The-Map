//
//  ListLocationsViewController.swift
//  On The Map
//
//  Created by Alex Paul on 7/30/15.
//  Copyright (c) 2015 Alex Paul. All rights reserved.
//

import UIKit

class ListLocationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentLocationCell") as! UITableViewCell
        
        return cell
    }

}
