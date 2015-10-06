//
//  StudentInformation.swift
//  On The Map
//
//  Created by Alex Paul on 8/8/15.
//  Copyright (c) 2015 Alex Paul. All rights reserved.
//
//  The StudentInformation struct is an Individual Student Location Downloaded from Parse

import Foundation
import MapKit

struct StudentInformation {
    
    var firstName: String!
    var lastName: String!
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    var mapString: String!
    var mediaURL: String?
    var uniqueKey: String!
    var updatedAt: String! // date string: 2015-03-09T22:07:09.593Z
    
    // User Links 
    var linkedInURL: String? = nil
    var websiteURL: String? = nil
    var imageURL: String? = nil
    
    init(studentInfoDictionary: [String: AnyObject]) {
        let result = studentInfoDictionary
        firstName = result["firstName"] as! String
        lastName = result["lastName"] as! String
        latitude = result["latitude"] as! CLLocationDegrees
        longitude = result["longitude"] as! CLLocationDegrees
        mapString = result["mapString"] as! String
        mediaURL = result["mediaURL"] as? String
        updatedAt = result["updatedAt"] as! String
    }

}
