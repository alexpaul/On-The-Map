//
//  InformationPostingVC.swift
//  On The Map
//
//  Created by Alex Paul on 8/3/15.
//  Copyright (c) 2015 Alex Paul. All rights reserved.
//
//  Here a Student can share their location and a link to be Posted on Parse 

import UIKit
import MapKit

class InformationPostingVC: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var studentLocationTextField: UITextField!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var promptTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mediaURLTextField: UITextField!
    @IBOutlet weak var browseLinksButton: UIButton!
    
    
    var locationCoord: CLLocationCoordinate2D!
    let links = [OnTheMapClient.sharedInstance().linkedIInURL,
                OnTheMapClient.sharedInstance().websiteURL,
                OnTheMapClient.sharedInstance().imageURL]
    var selectedLink: String? = nil
    
    // MARK: View Life Cycle 
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        println("viewWillAppear")
        
        if let link = self.selectedLink {
            println("selected link: \(link)")
            self.mediaURLTextField.text = link
        }
    }
    
    // MARK: IBActions
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnTheMapButtonPressed(sender: UIButton) {
        processPlacemarkUsingStudentLocation()
    }
    
    @IBAction func browseLinksButtonPressed(sender: UIButton) {
        
        // Create a UINavigation Controller 
        // Embed the Browse Links View Controller in the Instantiated Navigation Controller
        let browseLinksNavController = self.storyboard?.instantiateViewControllerWithIdentifier("BrowseLinksNavController") as? UINavigationController
        let browseLinksVC = self.storyboard?.instantiateViewControllerWithIdentifier("BrowseLinksViewController") as? BrowseLinksViewController
        let viewControllers = [browseLinksVC!]

        // Pass the Links Data to the Browse Links View Controller
        browseLinksVC?.links = self.links
        browseLinksNavController?.setViewControllers(viewControllers, animated: true)
        
        self.presentViewController(browseLinksNavController!, animated: true, completion: nil)
    }
    
    @IBAction func unwindToInformationPostingVC(sender: UIStoryboardSegue) {
        println("unwind segue")
        let browseLinksVC = sender.sourceViewController as! BrowseLinksViewController
        self.selectedLink = browseLinksVC.selectedLink
        println("link in unwind segue: \(self.selectedLink)")
    }
    
    
    // MARK: MapViewDelegate Methods
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseID = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = false
            pinView!.pinColor = .Red
            
        }else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    // MARK: UITextFieldDelegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: Helper Methods
    
    func processPlacemarkUsingStudentLocation() {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(self.studentLocationTextField?.text) { (placemarks, error) in
            
            if (error != nil) {
                self.alertGeoLocationData()
                return
            }else {
                var lat: CLLocationDegrees!
                var long: CLLocationDegrees!
                var mark: CLPlacemark!
                
                for placemark in placemarks {
                    mark = placemark as! CLPlacemark
                    lat = mark.location.coordinate.latitude
                    long = mark.location.coordinate.longitude
                }
                // Create location annotation
                let annotation = MKPointAnnotation()
                self.locationCoord = CLLocationCoordinate2D(latitude: lat, longitude: long)
                annotation.coordinate = self.locationCoord
                
                // Add annotation to the Map View 
                self.mapView.addAnnotation(annotation)
                let coordinateSpan = MKCoordinateSpanMake(0.01, 0.01) // 1 degree is 69 miles, 0.01 is 1 mile
                let adjustedRegion = self.mapView.regionThatFits(MKCoordinateRegionMake(self.locationCoord, coordinateSpan))
                self.mapView.setRegion(adjustedRegion, animated: true)
                
                // Animate UI Elements during geocoding
                // Show MapView and other Relevant UI Elements
                self.animateMapViewAndRelevantUIElements()
            }
        }
    }
    
    func alertGeoLocationData() {
        let alert = UIAlertController(title: "Bad Geo Loocation Data", message: "Enter a valid Location", preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func alertMediaURLRequired() {
        let alert = UIAlertController(title: "Missing Media URL", message: "Media URL is Required", preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func alertPOSTFailed() {
        
    }
    
    func alertWhileModifyingStudentLocation(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func animateMapViewAndRelevantUIElements() {
        // Animate alpha/transparency of UI Elements during Geocoding
        UIView.animateWithDuration(0.8) {
            self.studentLocationTextField.alpha = 0.0
            self.findOnTheMapButton.alpha = 0.0
            self.promptTextView.alpha = 0.0
            
            // Toggle the Title of the Submit Button based on User Location Existing or Not
            // In the case Location exist, Update
            // If there's No existing Location, Submit a New Location
            if OnTheMapClient.sharedInstance().locationExists! {
                self.submitButton.setTitle("Update Location", forState: UIControlState.Normal)
            }else {
                self.submitButton.setTitle("Submit Location", forState: UIControlState.Normal)
            }
            self.submitButton.alpha = 1.0
            self.mapView.alpha = 1.0
            self.mediaURLTextField.alpha = 1.0
            self.browseLinksButton.alpha = 1.0
        }
    }
    
    @IBAction func submitButtonPressed(sender: UIButton) {
        
        if self.mediaURLTextField.text.isEmpty {
            // Media URL is Required
            self.alertMediaURLRequired()
        }else {
            let latitude = self.locationCoord.latitude as Double
            let longitude = self.locationCoord.longitude as Double
            let mapString = self.studentLocationTextField.text
            let mediaURL = self.mediaURLTextField.text
            
            if let locationExist = OnTheMapClient.sharedInstance().locationExists {
                if locationExist { // A Location Exist For the Student. Update!
                    
                    OnTheMapClient.sharedInstance().updateStudentLocation(mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude, completionHandler: { (success, result, error) -> Void in
                        if error != nil {
                            println("PUT Update Failed with error: \(error?.localizedDescription)")
                            self.alertWhileModifyingStudentLocation("Updating Location", message: "\(error?.localizedDescription)")
                        }else {
                            self.alertWhileModifyingStudentLocation("Updating Location", message: "\(result)")
                        }
                    })
                }else { // A Location Does Not Exist for the Student. Add!
                    
                    OnTheMapClient.sharedInstance().postStudentLocation(mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude) { (success, result, error) in
                        if error != nil {
                            println("POST Failed with error: \(error?.localizedDescription)")
                            self.alertWhileModifyingStudentLocation("Adding Location", message: "\(error?.localizedDescription)")
                        }else {
                            self.alertWhileModifyingStudentLocation("Adding Location", message: "\(result)")
                        }
                    }
                }
                
                // Get Updated Location Data from Parse
                OnTheMapClient.sharedInstance().getStudentLocations({ (success, result, error) -> Void in
                    if (error != nil) {
                        println("Getting Student Locations Error: \(error?.localizedDescription)")
                    }
                })
            }

        }
        
    }
    
}
