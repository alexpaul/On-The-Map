//
//  MapLocationsViewController.swift
//  On The Map
//
//  Created by Alex Paul on 7/30/15.
//  Copyright (c) 2015 Alex Paul. All rights reserved.
//
//  Uses a MapView to show Student Locations via Pin Annotations

import UIKit
import MapKit
import FBSDKLoginKit
import FBSDKCoreKit

class MapLocationsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Array will hold Annotations
    var annotations = [MKPointAnnotation]()
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Create two (2) Button Bar Items on the Right Side of the Navigation Bar
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshButtonPressed")
        let postButton = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "postButtonPressed")
        self.navigationController?.navigationBar.topItem?.rightBarButtonItems = [refreshButton, postButton]
        
        self.activityIndicator.hidesWhenStopped = true
        
        let delay = 4.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        self.activityIndicator.startAnimating()
        
        dispatch_after(time, dispatch_get_main_queue()) {
            self.activityIndicator.stopAnimating()
            
            // Create Location Annotations
            self.createLocationAnnotations()
            
            // Add Annotations to the Map View
            self.mapView.addAnnotations(self.annotations)
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: IBActions 
    
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        
        // Logout of Udacity
        OnTheMapClient.sharedInstance().logoutUdacitySession()
        
        // Logout of Facebook
        FBSDKLoginManager().logOut()
        
        // Dismiss View Controller and Return to Login Screen
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: CLLocation Manager Delegate 
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse) {
            manager.startUpdatingLocation()
        }
    }
    
    
    // MARK: Map View Delegate
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseID = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
            pinView?.pinColor = .Red
            pinView?.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        
        if control == view.rightCalloutAccessoryView {
            UIApplication.sharedApplication().openURL(NSURL(string: view.annotation.subtitle!)!)
        }
    }
    
    // MARK: Helper Methods 
    
    func createLocationAnnotations() {
        for location in OnTheMapClient.sharedInstance().studentLocations {
            
            let lat = location.latitude as Double
            let long = location.longitude as Double
            
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = location.firstName!
            let last = location.lastName!
            
            // Create the annotation and set its coordinate, title and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.title = first + " " + last
            annotation.coordinate = coordinate
            
            if let mediaURL = location.mediaURL {
                annotation.subtitle = mediaURL
            }
            
            self.annotations.append(annotation)
        }
    }
    
    func postButtonPressed() {
        let infoPostVC = self.storyboard?.instantiateViewControllerWithIdentifier("InformationPostingVC") as! InformationPostingVC
        self.navigationController?.presentViewController(infoPostVC, animated: true, completion: nil)
    }
    
    func refreshButtonPressed() {
        
        // Download the Students Locations from Parse
        OnTheMapClient.sharedInstance().getStudentLocations { (success, result, error) in
            if error != nil {
                self.downloadAlertMessage()
                // Error downloading student locations
            }else {
                if let res = result {
                    // student locations
                }else {
                    // Error retrieving student locations
                }
                
            }
        }
        
        let delay = 4.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        self.activityIndicator.startAnimating()
        
        // Remove Annotations from Map View
        self.mapView.removeAnnotations(self.annotations)
        
        // Clear Annotations Array
        self.annotations.removeAll(keepCapacity: false)
        
        // Clear Student Locations
        OnTheMapClient.sharedInstance().studentLocations.removeAll(keepCapacity: false)
        
        dispatch_after(time, dispatch_get_main_queue()) {
            
            // Create Location Annotations
            self.createLocationAnnotations()
            
            // Add Annotations to the Map View
            self.mapView.addAnnotations(self.annotations)
            
            self.activityIndicator.stopAnimating()
        }
        
    }
    
    func downloadAlertMessage() {
        let alertController = UIAlertController(title: "Download Error", message: "Failed to Download Student Locations", preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(alertAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    
}
