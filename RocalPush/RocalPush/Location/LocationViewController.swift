//
//  LocationViewController.swift
//  RocalPush
//
//  Created by wooky83 on 28/08/2019.
//  Copyright © 2019 wooky. All rights reserved.
//

import UIKit
import MapKit

final class LocationViewController: UIViewController, SegueHandlerType {
    @IBOutlet private weak var map: MKMapView!
    @IBOutlet private weak var address: UITextField!
    @IBOutlet private weak var doneButton: UIBarButtonItem!
    
    enum SegueIdentifier: String {
        case locationDetails
    }
    
    private let geocoder = CLGeocoder()
    private let metersPerMile = 1609.344
    private let locationManager = CLLocationManager()
    
    private var coordinate: CLLocationCoordinate2D?
    private var annotation: MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        address.isEnabled = false
        doneButton.isEnabled = false
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted:
            let message = "This device is not allowed to use location services."
            UIAlertController.okWithMessage(message, presentingViewController: self)
            
        case .denied:
            let message = "Location services must be enabled."
            UIAlertController.okWithMessage(message, presentingViewController: self)
            
        case .authorizedWhenInUse:
            address.becomeFirstResponder()
            address.isEnabled = true
            doneButton.isEnabled = true
            
        default:
            break
        }
        
        locationManager.startUpdatingLocation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segueIdentifier(forSegue: segue) == .locationDetails,
            let destination = segue.destination as? LocationDetailsViewController,
            let coordinate = coordinate else {
                return
        }
        
        destination.coordinate = coordinate
    }
    
    private func showAddressOnMap(address: String) {
        geocoder.geocodeAddressString(address) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            guard error == nil else {
                UIAlertController.okWithMessage("Address lookup failed.", presentingViewController: self)
                return
            }
            
            guard let placemark = placemarks?.first,
                let coordinate = placemark.location?.coordinate else {
                    UIAlertController.okWithMessage("No available region found.", presentingViewController: self)
                    return
            }
            
            self.coordinate = coordinate
            
            if let annotation = self.annotation {
                self.map.removeAnnotation(annotation)
            }
            
            self.annotation = MKPointAnnotation()
            self.annotation!.coordinate = coordinate
            
            if let thoroughfare = placemark.thoroughfare {
                if let subThoroughfare = placemark.subThoroughfare {
                    self.annotation!.title = "\(subThoroughfare) \(thoroughfare)"
                } else {
                    self.annotation!.title = thoroughfare
                }
            } else {
                self.annotation!.title = address
            }
            
            self.map.addAnnotation(self.annotation!)
            
            let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: self.metersPerMile, longitudinalMeters: self.metersPerMile)
            self.map.setRegion(viewRegion, animated: true)
        }
    }
    
    @IBAction private func searchButtonPressed() {
        guard let addressToSearchFor = address.toTrimmedString() else {
            UIAlertController.okWithMessage("Please enter an address.", presentingViewController: self)
            return
        }
        
        address.resignFirstResponder()
        
        showAddressOnMap(address: addressToSearchFor)
    }
    
    @IBAction private func doneButtonTouched() {
        guard let _ = coordinate else {
            UIAlertController.okWithMessage("Please set a location first.", presentingViewController: self)
            return
        }
        
        performSegue(withIdentifier: .locationDetails, sender: self)
    }
}

extension LocationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchButtonPressed()
        textField.resignFirstResponder()
        
        return true
    }
}

extension LocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let authorized = status == .authorizedWhenInUse
        
        address.isEnabled = authorized
        doneButton.isEnabled = authorized
        
        if authorized {
            address.becomeFirstResponder()
        }
    }
}

