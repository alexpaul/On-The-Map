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

class MapLocationsViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var studentLocations = [StudentInformation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.activityIndicator.hidesWhenStopped = true
        
        let delay = 4.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        self.activityIndicator.startAnimating()
        
        dispatch_after(time, dispatch_get_main_queue()) {
            self.activityIndicator.stopAnimating()
            // Get the Students Locations from the Parse API
            self.studentLocations = OnTheMapClient.sharedInstance().studentLocations
                        
            // Array will hold Annotations
            var annotations = [MKPointAnnotation]()
            
            for location in self.studentLocations {
                
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

                annotations.append(annotation)
            }
            self.mapView.addAnnotations(annotations)
        }

    }
    
    
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
    
}
