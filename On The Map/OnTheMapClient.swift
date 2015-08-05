//
//  OnTheMapClient.swift
//  On The Map
//
//  Created by Alex Paul on 7/30/15.
//  Copyright (c) 2015 Alex Paul. All rights reserved.
//

import Foundation

class OnTheMapClient {
    
    let session = NSURLSession.sharedSession()
    
    var sessionID: String? = nil
    
    var studentLocations = [[String: AnyObject]]()
    
    func authenticateUser(#username: String, password: String, completionHandler:(success: Bool, result: AnyObject!, error: String?) -> Void) {
        let parameters = [String: AnyObject]()
        
        let url = "https://www.udacity.com/api/session"
        let urlString = NSURL(string: url)!
        
        let request = NSMutableURLRequest(URL: urlString)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)

        
        let task = session.dataTaskWithRequest(request) { (data, response, downloadError) in
            if let err = downloadError {
                println("Error with Requesting Data")
            }else {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                
                var jsonError: NSError? = nil
                let jsonResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as? NSDictionary
                
                if let result = jsonResult {
                    if let accountDictionary = result.valueForKey("account") as? NSDictionary {
                        if let sessionDictionary = result.valueForKey("session") as? NSDictionary {
                            // Store the Session ID
                            OnTheMapClient.sharedInstance().sessionID = sessionDictionary.valueForKey("id") as? String
                            completionHandler(success: true, result: result, error: nil)
                        }
                    }else{
                        completionHandler(success: false, result: nil, error: "Error with Login")
                    }
                }else {
                    println("Error with JSON Result")
                }
            }
        }
        task.resume()
    }
    
    func getStudentLocations() {
        let url = "https://api.parse.com/1/classes/StudentLocation"
        let urlString = NSURL(string: url)!
        
        let request = NSMutableURLRequest(URL: urlString)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTaskWithRequest(request) { (data, response, downloadError) in
            var jsonError: NSError? = nil
            let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as! [String : AnyObject]
            
            if let err = jsonError {
                println("Error - JSON Parsing")
                return
            }else {
                // Save the downloaded Student locations
                self.studentLocations = parsedResult["results"] as! [[String : AnyObject]]
                println("\nthere are \(self.studentLocations.count) locations in OnTheMapClient")
            }
        }
        
        task.resume()
    }
    
    // MARK: Shared Instance using Singleton methodology
    
    class func sharedInstance() -> OnTheMapClient {
        
        struct Singleton {
            static var sharedIntance = OnTheMapClient()
        }
        
        return Singleton.sharedIntance
    }
}
