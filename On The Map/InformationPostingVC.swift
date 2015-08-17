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
    
    func alertPOSTFailed() {
        
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
        self.browseLinksButton.hidden = false 
    }
    
    @IBAction func submitButtonPressed(sender: UIButton) {
        
        let latitude = self.locationCoord.latitude as Double
        let longitude = self.locationCoord.longitude as Double
        let mapString = self.studentLocationTextField.text
        let mediaURL = self.mediaURLTextField.text
        
        println(OnTheMapClient.sharedInstance().locationExists)
        
        if let locationExist = OnTheMapClient.sharedInstance().locationExists {
            if locationExist {
                // TODO: Alert user that the Student Location Already Exist
                println("Alert user that the Student Location Already Exist")
            }else {
                // Add the Student Location to Parse
                println("Adding.......Student Location to Parse")
                OnTheMapClient.sharedInstance().postStudentLocation(mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude) { (success, result, error) in
                    if error != nil {
                        // TODO: Add an Alert to inform the user that the POST Failed
                        println("POST Failed with Error: \(error?.localizedDescription)")
                    }
                }
            }
        }
        
    }
    

}
