//
//  InformationPostingVC.swift
//  On The Map
//
//  Created by Alex Paul on 8/3/15.
//  Copyright (c) 2015 Alex Paul. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingVC: UIViewController {
    
    @IBOutlet weak var studentLocationTextField: UITextField!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var promptTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mediaURLTextField: UITextField!
    
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide Map View and other associated UI Elements
        self.mapView.hidden = true
        self.submitButton.hidden = true
        self.mediaURLTextField.hidden = true
    }

    
    // MARK: IBActions
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnTheMapButtonPressed(sender: UIButton) {
        processPlacemarkUsingStudentLocation()
    }
    
    
    // MARK: Helper Methods
    
    func processPlacemarkUsingStudentLocation() {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(self.studentLocationTextField?.text) { (placemarks, error) in
            
            if (error != nil) {
                self.alertLocation()
                return
            }else {
                // Hide UI Elements if geocoding was successful
                self.hideInitialUIElements()
                for placemark in placemarks {
                    let mark = placemark as! CLPlacemark
                    let lat = mark.location.coordinate.latitude
                    let long = mark.location.coordinate.longitude
                    println("\(lat) \(long)")
                }
            }
        }
    }
    
    func alertLocation() {
        let alert = UIAlertController(title: "Bad Location Data", message: "Enter a valid Location", preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func hideInitialUIElements() {
        studentLocationTextField.hidden = true
        findOnTheMapButton.hidden = true
        promptTextView.hidden = true
        
        // Unhide Map View and other relevant UI Elements
        self.mapView.hidden = false
        self.submitButton.hidden = false
        self.mediaURLTextField.hidden = false
    }

}
