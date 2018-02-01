//
//  StoreLocator.swift
//  DealBuddy
//
//  Created by Ryan Fritsch on 4/17/17.
//  Copyright © 2017 Ryan Fritsch. All rights reserved.
//

import UIKit
import MapKit

class StoreLocator: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate  {
    
    
    @IBOutlet weak var searchB: UISearchBar!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!

    
    var userLocaiton: MKUserLocation!
    var locationManager: CLLocationManager!
    
    var items: [String] = ["We", "Heart", "Swift"]
    
    var matchingItems: [MKMapItem] = [MKMapItem]()
    
    var mapZoomed = false;
    
    var foundAdd: String! = "Select Location";
    var foundLong: Double! = 0.0;
    var foundLat: Double! = 0.0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let graytb = UIColor(red: 40/255, green: 40/255, blue: 44/255, alpha: 1.0)
        navigationController!.navigationBar.barTintColor = graytb
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        self.createLocationManager()
        
        self.mapView.showsUserLocation = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchB.delegate = self
        
        
        //let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(StoreLocator.dismissKeyboard))
        
        //view.addGestureRecognizer(tap)
        
        
    }
    
    @IBAction func findButton(sender: AnyObject) {
        
        if(!mapZoomed){
            let userLocation = mapView.userLocation
        
            let region = MKCoordinateRegionMakeWithDistance(
                (userLocation.location?.coordinate)!, 4000, 5000)
        
            mapView.setRegion(region, animated: false)
        
            mapView.removeAnnotations(mapView.annotations)
            
            mapZoomed = true
        }
        
        self.performSearch(input: searchB.text!)
        self.tableView.reloadData()
    }
    
    
    func createLocationManager () {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        
    }
    
    
    func locationManager (manager:CLLocationManager!, didUpdateLocations locations:[AnyObject]!) {
        if let firstlocation = locations.first as? CLLocation {
            mapView.setCenter(firstlocation.coordinate, animated: true)
            let region = MKCoordinateRegionMakeWithDistance((mapView.userLocation.location?.coordinate)!, 2000, 2000)
            mapView.setRegion(region, animated: false)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.matchingItems.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MerchCell", for: indexPath as IndexPath)
            as! UITableViewCell
        
        let locat = matchingItems[indexPath.row] as MKMapItem
        
        cell.textLabel?.text = locat.name!
        
        if let thr = locat.placemark.thoroughfare {
            cell.textLabel?.text?.append(" - " + locat.placemark.thoroughfare!)
        }
        
        
        
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let locat = matchingItems[indexPath.row] as MKMapItem
        
        self.foundAdd = locat.name! + " - " + locat.placemark.thoroughfare! + ", " + locat.placemark.locality! + ", ";
        
        self.foundAdd.append(locat.placemark.administrativeArea! + " ")
        
        self.foundAdd.append(locat.placemark.postalCode!)
        
        self.foundLat = locat.placemark.location?.coordinate.latitude
        self.foundLong = locat.placemark.location?.coordinate.longitude
        
        self.performSegue(withIdentifier: "gotoadddeal", sender: self)
    }
    
    
    
    func performSearch(input: String) {
        
        matchingItems.removeAll()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = input
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            guard let response = response else {
                print("There was an error searching for: \(request.naturalLanguageQuery) error: \(error)")
                
                let alertController = UIAlertController(title: "ERROR", message: "There was an error while searching. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    print("OK")
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            //print("Matches found")
            
            if(response.mapItems.count != 0){
            
                for item in response.mapItems as! [MKMapItem] {
//                    print("\n\n\n")
//                    print("Name = \(item.name)")
//                    print("Phone = \(item.phoneNumber)")
            
                    self.matchingItems.append(item as MKMapItem)
                    //print("Matching items = \(self.matchingItems.count)")
            
                    var annotation = MKPointAnnotation()
//                    print("Latitude = \(item.placemark.coordinate.latitude)")
//                    print("Longitude = \(item.placemark.coordinate.longitude)")
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    self.mapView.addAnnotation(annotation)
                    
                }
                self.tableView.reloadData()
            }
        }
        
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
    
        if((searchB.text?.characters.count)! >= 3){
            
            if(!mapZoomed){
                let userLocation = mapView.userLocation
                
                let region = MKCoordinateRegionMakeWithDistance(
                    (userLocation.location?.coordinate)!, 4000, 5000)
                
                mapView.setRegion(region, animated: false)
                
                mapView.removeAnnotations(mapView.annotations)
                
                mapZoomed = true
            }
            
            self.performSearch(input: searchB.text!)
            self.tableView.reloadData()
            
        }
    
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        if(!mapZoomed){
            let userLocation = mapView.userLocation
            
            let region = MKCoordinateRegionMakeWithDistance(
                (userLocation.location?.coordinate)!, 4000, 5000)
            
            mapView.setRegion(region, animated: false)
            
            mapView.removeAnnotations(mapView.annotations)
            
            mapZoomed = true
        }
        
        self.performSearch(input: searchB.text!)
        self.tableView.reloadData()
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "gotoadddeal"){
            
            if let addDeal: AddDeal = segue.destination as? AddDeal
            {
                addDeal.foundStreetAddress = self.foundAdd;
                addDeal.foundLongitude = self.foundLong!;
                addDeal.foundLatitude = self.foundLat;
            }
        }
    }

}















