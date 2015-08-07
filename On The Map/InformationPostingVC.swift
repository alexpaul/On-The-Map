//
//  InformationPostingVC.swift
//  On The Map
//
//  Created by Alex Paul on 8/3/15.
//  Copyright (c) 2015 Alex Paul. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var studentLocationTextField: UITextField!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var promptTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mediaURLTextField: UITextField!
    
    var locationCoord: CLLocationCoordinate2D!
    
    // MARK: IBActions
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnTheMapButtonPressed(sender: UIButton) {
        processPlacemarkUsingStudentLocation()
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
    
    
    // MARK: Helper Methods
    
    func processPlacemarkUsingStudentLocation() {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(self.studentLocationTextField?.text) { (placemarks, error) in
            
            if (error != nil) {
                self.alertLocation()
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
                
                // Hide Initial UI Elements if geocoding was successful
                // Show MapView and other Relevant UI Elements
                self.showMapViewAndRelevantUIElements()
            }
        }
    }
    
    func alertLocation() {
        let alert = UIAlertController(title: "Bad Location Data", message: "Enter a valid Location", preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showMapViewAndRelevantUIElements() {
        studentLocationTextField.hidden = true
        findOnTheMapButton.hidden = true
        promptTextView.hidden = true
        
        // Unhide Map View and other relevant UI Elements
        unhideMapViewAndOtherUIElements()
    }
    
    func unhideMapViewAndOtherUIElements() {
        self.mapView.hidden = false
        self.submitButton.hidden = false
        self.mediaURLTextField.hidden = false
    }
    
    @IBAction func submitButtonPressed(sender: UIButton) {
        
        let latitude = self.locationCoord.latitude as Double
        let longitude = self.locationCoord.longitude as Double
        let mapString = self.studentLocationTextField.text
        let mediaURL = self.mediaURLTextField.text
        
        // Query if Student Location Already Exist
        // If it Exist, Alert User that Location Exist in Parse
        // If it Does Not Exist, Add the Location to Parse
        let locationExist = OnTheMapClient.sharedInstance().queryStudentLocationExistInParse()
        
        if locationExist {
            // TODO: Alert user that the Student Location Already Exist
            println("Alert user that the Student Location Already Exist")
        }else {
            // TODO: Add the Student Location to Parse
            println("Add the Student Location to Parse")
            OnTheMapClient.sharedInstance().postStudentLocation(mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude)
        }
        
        
    }
    

}
