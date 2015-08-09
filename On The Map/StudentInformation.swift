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
}
