//
//  CloudKitModel.swift
//  DealBuddy
//
//  Created by Ryan Fritsch on 4/19/17.
//  Copyright © 2017 Ryan Fritsch. All rights reserved.
//

import Foundation
import CloudKit
import UIKit



// Specify the protocol to be used by view controllers to handle notifications.
protocol CloudKitModelDelegate {
    func modelUpdated()
    func refreshDone()
    func errorUpdating(_ error: NSError)
    func noIcloud()
    func locationNotAllowed()
}

class CloudKitModel {
    
    
    var inputLat = 0.0;
    var inputLong = 0.0;
    
    static let sharedInstance = CloudKitModel()
    
    var delegate: CloudKitModelDelegate?
    
    let myContainer: CKContainer
    let publicDatabase: CKDatabase
    let privateDB: CKDatabase
    
    
    // MARK: - Initializers
    init() {
        myContainer = CKContainer(identifier: "////////////SENSITIVE/////////////")
        publicDatabase = myContainer.publicCloudDatabase
        privateDB = myContainer.privateCloudDatabase
    }


    func saveNewDeal(name: String, price: Double, description: String, address: String, latitude: Double, longitude: Double, image: UIImage?){
        
        
        let randomID = randomString(length: 10);
        
        let documentsDirectoryPath:NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        var imageURL: URL!
        let tempImageName = "\(randomID).jpg"
        var uploadedImage: CKAsset!
        
        if let imageIn = image {
            
            let imageData:Data = UIImageJPEGRepresentation(imageIn, 1.0)!
            let path:String = documentsDirectoryPath.appendingPathComponent(tempImageName)
            try? UIImageJPEGRepresentation(imageIn, 1.0)!.write(to: URL(fileURLWithPath: path), options: [.atomic])
            imageURL = URL(fileURLWithPath: path)
            try? imageData.write(to: imageURL, options: [.atomic])
            
            uploadedImage = CKAsset(fileURL: URL(fileURLWithPath: path))
        }

        
        let dealLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        //let imageAsset = CKAsset(fileURL: image)
        
        let dealRecordID = CKRecordID(recordName: randomID)
        let dealRecord = CKRecord(recordType: "Deal", recordID: dealRecordID)
        
        dealRecord["title"] = name as NSString
        dealRecord["price"] = price as NSNumber
        dealRecord["description"] = description as NSString
        dealRecord["address"] = address as NSString
        dealRecord["location"] = dealLocation as CLLocation
        dealRecord["rating"] = 0 as NSNumber
        dealRecord["image"] = uploadedImage! as CKAsset
        dealRecord["creation"] = Date() as NSDate
        
        let thisDeal = Deal(name: name, price: price, notes: description, locat: address, latitude: dealLocation.coordinate.latitude, longitude: dealLocation.coordinate.longitude, score: 0, image: image!, id: randomID)
        
        dealDict[randomID] = dealRecord;
        deals.insert(thisDeal, at: 0)
        
        publicDatabase.save(dealRecord) {
            (record, error) in
            if let error = error {
                
            }
            DispatchQueue.main.async {
                self.delegate?.modelUpdated()
            }
        }
        
    }
    
    
    func updateDeal(dealID: String, vote: Int){
        
        var updateRecord = dealDict[dealID]! as CKRecord
        var currentRating = updateRecord.object(forKey: "rating") as! Int
        
        currentRating += vote;
        
        updateRecord["rating"] = currentRating as NSNumber

        
        var dealRecord = updateRecord
        
        DispatchQueue.main.async {
            self.publicDatabase.save(dealRecord) {
                (record, error) in
                if let error = error {
                
                }
            }
        }
        
        
    }

    
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }


    
    func refresh(_ location:CLLocation, radiusInMeters: CGFloat) {
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse){
            
            dealDict.removeAll()
            deals.removeAll()
            
            self.inputLong = location.coordinate.longitude
            self.inputLat = location.coordinate.latitude
            
            //print(self.inputLat, self.inputLong)
            
            let predicate = NSPredicate(format: "distanceToLocation:fromLocation:(location, %@) < %f", location, radiusInMeters)
            
            let query = CKQuery(recordType: "Deal", predicate: predicate)
            
            
            publicDatabase.perform(query, inZoneWith: nil) { results, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.delegate?.errorUpdating(error as NSError)
                    }
                    return
                }
                
                
                results!.forEach({ (record: CKRecord) in
                    
                    var created = (record.object(forKey: "creation") as! NSDate)
                    var now = Date() as NSDate
                    
                    let formatter = DateComponentsFormatter()
                    formatter.allowedUnits = [.day]
                    formatter.unitsStyle = .full
                    let days = formatter.string(from: created as Date, to: now as Date)!
                    
                    if let number = Int(days.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                        if(number >= 7){
                            self.publicDatabase.delete(withRecordID: CKRecordID(recordName: record.recordID.recordName), completionHandler: {recordID, error in
                                print("DELETE");
                            })
                        } else {
                            
                            var dname = record.object(forKey: "title") as! String
                            var dprice = record.object(forKey: "price") as! Double
                            var dnotes = record.object(forKey: "description") as! String
                            var dlocation = record.object(forKey: "address") as! String
                            var dloc = record.object(forKey: "location") as! CLLocation
                            var dlat = dloc.coordinate.latitude
                            var dlon = dloc.coordinate.longitude
                            var dscore = record.object(forKey: "rating") as! Int
                            
                            // IMAGE
                            guard let asset = record.object(forKey: "image") as? CKAsset else{ return }
                            
                            let imageData: Data
                            do {
                                imageData = try Data(contentsOf: asset.fileURL)
                            } catch {
                                return
                            }
                            var dimage = UIImage(data: imageData)
                            
                            var dId = record.recordID.recordName as! String
                            
                            
                            
                            let thisDeal = Deal(name: dname, price: dprice, notes: dnotes, locat: dlocation, latitude: dlat, longitude: dlon, score: dscore, image: dimage!, id: dId)
                            
                            dealDict[dId] = record as! CKRecord;
                            deals.append(thisDeal)
                            
                        }
                    }
                    
                    
                })
                
                DispatchQueue.main.async {
                    self.delegate?.refreshDone()
                }
                
            }
            
        } else {
            
            DispatchQueue.main.async {
                self.delegate?.locationNotAllowed()
            }
            print("Location Unavailable")
            
        }
        
    }



    
    func fetchDeals(_ location:CLLocation, radiusInMeters: CGFloat) {
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse){
        
            dealDict.removeAll()
            deals.removeAll()
            
            self.inputLong = location.coordinate.longitude
            self.inputLat = location.coordinate.latitude
            
            //print(self.inputLat, self.inputLong)
            
            let predicate = NSPredicate(format: "distanceToLocation:fromLocation:(location, %@) < %f", location, radiusInMeters)
            
            let query = CKQuery(recordType: "Deal", predicate: predicate)
            
            
            publicDatabase.perform(query, inZoneWith: nil) { results, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.delegate?.errorUpdating(error as NSError)
                    }
                    return
                }
                
                
                results!.forEach({ (record: CKRecord) in
                    
                    var created = (record.object(forKey: "creation") as! NSDate)
                    var now = Date() as NSDate
                    
                    let formatter = DateComponentsFormatter()
                    formatter.allowedUnits = [.day]
                    formatter.unitsStyle = .full
                    let days = formatter.string(from: created as Date, to: now as Date)!
                    
                    if let number = Int(days.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                        if(number >= 7){
                            self.publicDatabase.delete(withRecordID: CKRecordID(recordName: record.recordID.recordName), completionHandler: {recordID, error in
                                print("DELETE");
                            })
                        } else {
                            
                            var dname = record.object(forKey: "title") as! String
                            var dprice = record.object(forKey: "price") as! Double
                            var dnotes = record.object(forKey: "description") as! String
                            var dlocation = record.object(forKey: "address") as! String
                            var dloc = record.object(forKey: "location") as! CLLocation
                            var dlat = dloc.coordinate.latitude
                            var dlon = dloc.coordinate.longitude
                            var dscore = record.object(forKey: "rating") as! Int
                            
                            // IMAGE
                            guard let asset = record.object(forKey: "image") as? CKAsset else{ return }
                            
                            let imageData: Data
                            do {
                                imageData = try Data(contentsOf: asset.fileURL)
                            } catch {
                                return
                            }
                            var dimage = UIImage(data: imageData)
                            
                            var dId = record.recordID.recordName as! String
                            
                            
                            
                            let thisDeal = Deal(name: dname, price: dprice, notes: dnotes, locat: dlocation, latitude: dlat, longitude: dlon, score: dscore, image: dimage!, id: dId)
                            
                            dealDict[dId] = record as! CKRecord;
                            deals.append(thisDeal)
                            
                        }
                    }
                    
                    
                })
                
                DispatchQueue.main.async {
                    self.delegate?.modelUpdated()
                }
                
            }

        } else {
        
            DispatchQueue.main.async {
                self.delegate?.locationNotAllowed()
            }
            print("Location Unavailable")
        
        }

    }
    
}









