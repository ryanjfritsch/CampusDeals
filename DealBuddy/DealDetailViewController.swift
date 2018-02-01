//
//  DealDetailViewController.swift
//  DealBuddy
//
//  Created by Ryan Fritsch on 3/20/17.
//  Copyright © 2017 Ryan Fritsch. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CloudKit
import CoreData

class DealDetailViewController: UIViewController {
    
    // DEAL VARIABLES
    var dName:String! = ""
    var dPrice:Double!
    var dPriceString:String? = ""
    var dNotes:String! = ""
    var dLocat:String! = ""
    var dLong:Double!
    var dLat:Double!
    var dScore: Int!
    var dImage: UIImage!
    var dID: String!
    var voted: Int16! = 0
    var changeVote = false;
    var changeScoreTo = 0;

    
    // VC ATTRIBUTES
    
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var upVote: UIButton!
    @IBOutlet weak var downVote: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var locButton: UIButton!
    @IBOutlet weak var notesField: UITextView!
    @IBOutlet weak var productImage: UIImageView!
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    var userVotesPre: [NSManagedObject] = []
    var userVotes = [String: Int16]()
    var vHelp = UserDataHelper()

    
    let accG = UIColor(red: 36/255, green: 108/255, blue: 0/255, alpha: 1.0)
    let accR = UIColor(red: 212/255, green: 6/255, blue: 0/255, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userVotesPre = vHelp.getVotes()
        
        for voteObj in userVotesPre {
            userVotes[voteObj.value(forKeyPath: "id") as! String] = voteObj.value(forKeyPath: "vote") as! Int16
        }
        
        if ((userVotes[dID]) != nil){
            self.voted = userVotes[dID]!
        }
        
        productName.text = dName;
        priceLabel.text = "$\(dPriceString!)";
        locButton.setTitle(" Click for directions to: \(dLocat!)", for: .normal);
        notesField.text = dNotes;
        scoreLabel.text = "\(dScore!)";
        productImage.image = dImage;
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        productImage.isUserInteractionEnabled = true
        productImage.addGestureRecognizer(tapGestureRecognizer)
        
        
        if(voted == -1){
            let imageU = UIImage(named: "up-arrow-2")?.withRenderingMode(.alwaysTemplate)
            upVote.setImage(imageU, for: .normal)
            upVote.tintColor = accG
            
            let imageD = UIImage(named: "down-arrow-3")?.withRenderingMode(.alwaysTemplate)
            downVote.setImage(imageD, for: .normal)
            downVote.tintColor = accR
        
        } else if(voted == 1){
            let imageU = UIImage(named: "up-arrow-3")?.withRenderingMode(.alwaysTemplate)
            upVote.setImage(imageU, for: .normal)
            upVote.tintColor = accG
            
            let imageD = UIImage(named: "down-arrow-2")?.withRenderingMode(.alwaysTemplate)
            downVote.setImage(imageD, for: .normal)
            downVote.tintColor = accR
        
        } else {
            let imageU = UIImage(named: "up-arrow-2")?.withRenderingMode(.alwaysTemplate)
            upVote.setImage(imageU, for: .normal)
            upVote.tintColor = accG
        
            let imageD = UIImage(named: "down-arrow-2")?.withRenderingMode(.alwaysTemplate)
            downVote.setImage(imageD, for: .normal)
            downVote.tintColor = accR

        }
        let graytb = UIColor(red: 40/255, green: 40/255, blue: 44/255, alpha: 1.0)
        
        navigationController!.navigationBar.barTintColor = graytb
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        // Create Location
        let location = CLLocation(latitude: dLat!, longitude: dLong!)
        
        // Geocode Location
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            // Process Response
            if let error = error {
                print("Unable to Reverse Geocode Location (\(error))")
                //locationLabel.text = "Unable to Find Address for Location"
                
            } else {
                
                if (placemarks?.count)! > 0
                {
                    let placemark = placemarks?[0];
                    let location = placemark?.location
                    
                    let span = MKCoordinateSpanMake(0.05, 0.05)
                    let region = MKCoordinateRegion(center: (placemark?.location!.coordinate)!, span: span)
                    self.mapView.setRegion(region, animated: false)
                    let ani = MKPointAnnotation()
                    ani.coordinate = (placemark?.location!.coordinate)!
                    ani.title = "\(self.dLocat!)"
                    self.mapView.addAnnotation(ani)
                    
                }
            }
        }
        
        mapView.showsUserLocation = true;
                
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    
    @IBAction func getDirections(_ sender: Any) {

        let coordinate = CLLocationCoordinate2DMake(dLat!, dLong!)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = dLocat
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        
    }
    
    
    @IBAction func upVoteTapped(_ sender: Any) {
        
        if(voted == 0){
            
            let imageU = UIImage(named: "up-arrow-3")?.withRenderingMode(.alwaysTemplate)
            upVote.setImage(imageU, for: .normal)
            upVote.tintColor = accG
            
            let imageD = UIImage(named: "down-arrow-2")?.withRenderingMode(.alwaysTemplate)
            downVote.setImage(imageD, for: .normal)
            downVote.tintColor = accR
            
            dScore = Int(scoreLabel.text!)!
            
            voted = 1
            dScore = dScore + 1;
            scoreLabel.text = "\(self.dScore!)"
            
            changeVote = true;
            changeScoreTo = self.dScore;

            
            var ckm = CloudKitModel()
            ckm.updateDeal(dealID: dID, vote: 1)
            
            var vH = UserDataHelper()
            vH.saveVote(idIn: dID, voteIn: 1)
            
        
        } else if(voted == -1){
            
            let imageU = UIImage(named: "up-arrow-3")?.withRenderingMode(.alwaysTemplate)
            upVote.setImage(imageU, for: .normal)
            upVote.tintColor = accG
            
            let imageD = UIImage(named: "down-arrow-2")?.withRenderingMode(.alwaysTemplate)
            downVote.setImage(imageD, for: .normal)
            downVote.tintColor = accR
            
            dScore = Int(scoreLabel.text!)!
            
            voted = 1
            dScore = dScore + 2;
            scoreLabel.text = "\(self.dScore!)"
            
            changeVote = true;
            changeScoreTo = self.dScore;

            
            var ckm = CloudKitModel()
            ckm.updateDeal(dealID: dID, vote: 2)
            
            var vH = UserDataHelper()
            vH.editVote(id: dID, newVote:  1)
        
        }
        
    }
    

    @IBAction func downVoteTapped(_ sender: Any) {
        
        if(self.voted == 0){
            
            let imageU = UIImage(named: "up-arrow-2")?.withRenderingMode(.alwaysTemplate)
            upVote.setImage(imageU, for: .normal)
            upVote.tintColor = accG
            
            let imageD = UIImage(named: "down-arrow-3")?.withRenderingMode(.alwaysTemplate)
            downVote.setImage(imageD, for: .normal)
            downVote.tintColor = accR
            
            dScore = Int(scoreLabel.text!)!
        
            voted = -1
            dScore = dScore - 1;
            scoreLabel.text = "\(self.dScore!)"
            
            changeVote = true;
            changeScoreTo = self.dScore;
            
            var ckm = CloudKitModel()
            ckm.updateDeal(dealID: dID, vote: -1)
            
            var vH = UserDataHelper()
            vH.saveVote(idIn: dID, voteIn: -1)
            
        
        } else if(voted == 1){
        
            let imageU = UIImage(named: "up-arrow-2")?.withRenderingMode(.alwaysTemplate)
            upVote.setImage(imageU, for: .normal)
            upVote.tintColor = accG
            
            let imageD = UIImage(named: "down-arrow-3")?.withRenderingMode(.alwaysTemplate)
            downVote.setImage(imageD, for: .normal)
            downVote.tintColor = accR
            
            dScore = Int(scoreLabel.text!)!
        
            self.voted = -1
            dScore = dScore - 2;
            scoreLabel.text = "\(self.dScore!)"
            
            changeVote = true;
            changeScoreTo = self.dScore;

        
            var ckm = CloudKitModel()
            ckm.updateDeal(dealID: dID, vote: -2)
            
            var vH = UserDataHelper()
            vH.editVote(id: dID, newVote: -1)
        
        }
    
        
    }
    
    func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "doneWithDetail"){
            
            if(changeVote){
                
                print("CHANGE")
                
                let tc = segue.destination as! AllDealsTableViewController
                
                tc.changeScore = self.changeScoreTo;
                tc.changeID = self.dID;

            }
            
        }
    
    
    }
    
    
    

}




















