//
//  OnTheMapClient.swift
//  On The Map
//
//  Created by Alex Paul on 7/30/15.
//  Copyright (c) 2015 Alex Paul. All rights reserved.
//
//  OnTheMapClient handles all HTTP requests 

import Foundation
import MapKit

class OnTheMapClient {
    
    let session = NSURLSession.sharedSession()
    var sessionID: String? = nil
    var userID: String? = nil
    var studentLocations = [StudentInformation]()
    var firstName: String? = nil
    var lastName: String? = nil
    var locationExists: Bool!
    
    // MARK: HTTP POST Methods
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
                            self.sessionID = sessionDictionary.valueForKey("id") as? String
                            // Store the User ID 
                            self.userID = accountDictionary.valueForKey("key") as? String
                            
                            // Download Public Udacity User Data
                            self.getPublicUserData()
                            completionHandler(success: true, result: result, error: nil)
                        }
                    }else{
                        completionHandler(success: false, result: nil, error: "Error with Account")
                    }
                }else {
                    println("Error with JSON Result")
                }
            }
        }
        task.resume()
    }
    
    func facebookAuthentication(accessToken: String, completionHandler: (success: Bool, result: AnyObject!, error: String?) -> Void) {
                
        let url = "https://www.udacity.com/api/session"
        let urlString = NSURL(string: url)!
        let request = NSMutableURLRequest(URL: urlString)
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"facebook_mobile\": {\"access_token\":\"\(accessToken)\"}}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let task = session.dataTaskWithRequest(request) { (data, response, downloadError) in
            if downloadError != nil {
                println("Error with Facebook Authentication")
                return
            }else {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) // subset of data response
                var jsonError: NSError? = nil
                let jsonResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as? NSDictionary
                println(jsonResult)
                
                if let result = jsonResult {
                    if let accountDictionary = result.valueForKey("account") as? [String: AnyObject] {
                        if let sessionDictionary = result.valueForKey("session") as? [String: AnyObject] {
                            // Store the User ID and Sesssion ID
                            self.userID = accountDictionary["key"] as? String
                            self.sessionID = (sessionDictionary["id"] as? String)
                            
                            // Download Public Udacity User Data
                            self.getPublicUserData()
                            completionHandler(success: true, result: result, error: nil)
                        }
                    }else {
                        completionHandler(success: false, result: result, error: "Error with Account")
                    }
                }else {
                    println("Error with JSON Result")
                }
            }
        }
        task.resume()
    }
    
    func postStudentLocation(mapString: String, mediaURL: String, latitude: Double, longitude: Double) {
        
        let url = "https://api.parse.com/1/classes/StudentLocation"
        let urlString = NSURL(string: url)!
        let request = NSMutableURLRequest(URL: urlString)
        
        let uniqueKey = self.userID!
        let firstName = self.firstName!
        let lastName = self.lastName!
        
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\", \"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\", \"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if downloadError != nil {
                println("Error Posting Student Location")
                return
            }else {
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! [String:AnyObject]
                println(parsedResult)
            }
        }
        task.resume()
    }
    
    // MARK: HTTP GET Methods
    
    func getPublicUserData() {
        
        let url = "https://www.udacity.com/api/users/\(self.userID!)"
        let urlString = NSURL(string: url)!
        let request = NSMutableURLRequest(URL: urlString)
        
        let task = session.dataTaskWithRequest(request) { (data, response, jsonError) in
            if jsonError != nil {
                println("Error Getting Public User Data")
                return
            }else {
                var parsingError: NSError? = nil
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) // subset response data
                let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! [String:AnyObject]
                let userDictionary = parsedResult["user"] as! [String:AnyObject]
                self.firstName = userDictionary["first_name"] as? String
                self.lastName = userDictionary["last_name"] as? String
            }
        }
        task.resume()
    }
    
    func getStudentLocations() {
        
        // Query if Student Location Already Exist
        // If it Exist, Alert User that Location Exist in Parse
        // If it Does Not Exist, Add the Location to Parse
        self.queryStudentLocationExistInParse()
        
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
                // Save the downloaded Student locations to an Array of StudentInformation Structs
                let resultsDictionary = parsedResult["results"] as! [[String: AnyObject]]
                
                for result in resultsDictionary {
                    var studentInfo = StudentInformation()
                    studentInfo.firstName = result["firstName"] as! String
                    studentInfo.lastName = result["lastName"] as! String
                    studentInfo.latitude = result["latitude"] as! CLLocationDegrees
                    studentInfo.longitude = result["longitude"] as! CLLocationDegrees
                    studentInfo.mapString = result["mapString"] as! String
                    studentInfo.mediaURL = result["mediaURL"] as? String
                    
                    self.studentLocations.append(studentInfo)
                }
            }
        }
        
        task.resume()
    }
    
    func queryStudentLocationExistInParse(){
        
        println("userID: \(self.userID!)")
        
        let url = "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22" + "\(self.userID!)" + "%22%7D"
        let urlString = NSURL(string: url)!
        let request = NSMutableURLRequest(URL: urlString)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTaskWithRequest(request) { (data, response, jsonError) in
            if jsonError != nil {
                println("Error Querying Student Location")
                return
            }else {
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                if let resultsArray = parsedResult.valueForKey("results") as? [[String: AnyObject]] {
                    for results in resultsArray {
                        if results["objectId"] as! String != "" {
                            // Student Location Exists
                            self.locationExists = true
                        }else {
                            // Student Location Does not Exist
                            self.locationExists = false
                        }
                    }
                }else {
                    println("Error Parsing Results")
                }

            }
        }
        task.resume()
    }
    
    // MARK: HTTP PUT Methods
    
    func updateStudentLocation() {
        
        let urlString = "https://api.parse.com/1/classes/StudentLocation/\(self.userID!)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(self.userID!)\", \"firstName\": \"Brad\", \"lastName\": \"Jones\",\"mapString\": \"South Beach, FL\", \"mediaURL\": \"https://techmeme.com\",\"latitude\": 25.7819, \"longitude\": 80.1363}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
        }
        task.resume()
    }
    
    // MARK: HTTP DELETE Methods 
    
    func logoutUdacitySession() {
        
        let url = "https://www.udacity.com/api/session"
        let urlString = NSURL(string: url)!
        let request = NSMutableURLRequest(URL: urlString)
        
        request.HTTPMethod = "DELETE"
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" {xsrfCookie = cookie}
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTaskWithRequest(request) { (data, response, jsonError) in
            if jsonError != nil {
                println("Error logging out")
                return
            }else {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as? NSDictionary
                
                println(parsedResult)
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
    
    // MARK: Helper Methods 
    
}
