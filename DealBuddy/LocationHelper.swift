//
//  LocationHelper.swift
//  DealBuddy
//
//  Created by Ryan Fritsch on 4/19/17.
//  Copyright © 2017 Ryan Fritsch. All rights reserved.
//

import Foundation
import MapKit
import UIKit

protocol LocationHelperDelegate {
    func locationFound(latIn: Double, lonIn: Double)
    func refreshFound(latIn: Double, lonIn: Double)
    func locationDenied()
    func locationAllowed()
}

class LocationHelper: NSObject, CLLocationManagerDelegate {

    var userLocation: MKUserLocation!
    
    var delegate: LocationHelperDelegate?
    static let sharedInstance = LocationHelper()

    var cLat = 0.0
    var cLon = 0.0
    
    var locManager: CLLocationManager!
    
    var currentLocation = CLLocation()
    
    // MARK: - Initializers
    override init() {
        locManager = CLLocationManager()
        //locManager.requestWhenInUseAuthorization()
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.distanceFilter = kCLDistanceFilterNone

    }

    
    func getuserLocation(){
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse){
            
            currentLocation = locManager.location!
            
            cLat = currentLocation.coordinate.latitude
            cLon = currentLocation.coordinate.longitude
            
            //print(cLat, cLon)
            
            if(cLat == 0.0 || cLon == 0.0){ print("ZEROS") }
            
            DispatchQueue.main.async {
                self.delegate?.locationFound(latIn: self.cLat, lonIn: self.cLon)
            }
            
        }
        
    }
    
    
    func getrefreshLocation(){
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse){
            
            currentLocation = locManager.location!
            
            cLat = currentLocation.coordinate.latitude
            cLon = currentLocation.coordinate.longitude
            
            //print(cLat, cLon)
            
            if(cLat == 0.0 || cLon == 0.0){ print("ZEROS") }
            
            DispatchQueue.main.async {
                self.delegate?.refreshFound(latIn: self.cLat, lonIn: self.cLon)
            }
            
        }
        
    }

    
    func setDelegate(){ locManager.delegate = self }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
        
            currentLocation = locManager.location!
        
            cLat = currentLocation.coordinate.latitude
            cLon = currentLocation.coordinate.longitude
        
            if(cLat == 0.0 || cLon == 0.0){ print("ZEROS") }
        
            DispatchQueue.main.async {
                self.delegate?.locationFound(latIn: self.cLat, lonIn: self.cLon)
            }
           
        case .denied:
            DispatchQueue.main.async {
                self.delegate?.locationDenied()
            }
            
        default:
            break
        }
    }

}





