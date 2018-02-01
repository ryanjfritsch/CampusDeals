//
//  AllDealsTableViewController.swift
//  DealBuddy
//
//  Created by Ryan Fritsch on 3/20/17.
//  Copyright © 2017 Ryan Fritsch. All rights reserved.
//

import UIKit
import MapKit
import CloudKit
import CoreData

final class AllDealsTableViewController: UITableViewController, UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var selectedIndex:Int? = nil
    var selectedSeg:Int? = nil
    var selectedName:String? = ""
    var selectedLong:Double? = 0.0
    var selectedLat:Double? = 0.0
    var selectedPrice = 0.0
    var selectedAcc = 0.0
    var selectedLoc = ""
    var selectedID = ""
    var selectedScore = 0
    
    var changeID: String! = ""
    var changeScore: Int! = 0
    
    var currentLongitude = 0.0;
    var currentLatitude = 0.0;
    
    var gData = false;
    var refreshing = false;
    
    var notZero = -1
    
    var alert = UIAlertController(title: nil, message: "Loading Deals", preferredStyle: .alert)
    
    var userVotesPre: [NSManagedObject] = []
    var userVotes = [String: Int16]()
    var vHelp = UserDataHelper()
    
    var addedDeal = false;
    
    let model: CloudKitModel = CloudKitModel.sharedInstance
    
    let LH: LocationHelper = LocationHelper.sharedInstance

    var filteredDeals = [Deal]()
    
    @IBAction func cancelToLocalDealsViewController(segue:UIStoryboardSegue) {}
    @IBAction func newDealAdded(segue:UIStoryboardSegue) {}
    
    var locationManager: CLLocationManager!
    var userLocation: MKUserLocation!
    
    let accG = UIColor(red: 36/255, green: 108/255, blue: 0/255, alpha: 1.0)
    let accR = UIColor(red: 212/255, green: 6/255, blue: 0/255, alpha: 1.0)

    @IBOutlet weak var searchB: UISearchBar!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let graytb = UIColor(red: 40/255, green: 40/255, blue: 44/255, alpha: 1.0)
        let graysb = UIColor(red: 71/255, green: 71/255, blue: 75/255, alpha: 1.0)
        
        navigationController!.navigationBar.barTintColor = graytb
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        self.searchController.searchBar.barTintColor = graysb
        
   
        
        self.searchController.searchBar.showsCancelButton = true
        let cancelButtonSearchButton = searchController.searchBar.value(forKeyPath: "cancelButton") as? UIButton
        cancelButtonSearchButton?.tintColor = UIColor.white;
        self.searchController.searchBar.showsCancelButton = false
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        imageView.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "priceTagLaunch")
        imageView.image = image
        
        navigationItem.titleView = imageView
        
        searchController.searchResultsUpdater = self as! UISearchResultsUpdating
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        self.searchB.delegate = self
    
        model.delegate = self
        LH.delegate = self
        
        self.userVotesPre = vHelp.getVotes()
        
        for voteObj in userVotesPre {
            userVotes[voteObj.value(forKeyPath: "id") as! String] = voteObj.value(forKeyPath: "vote") as! Int16
        }
        
        
        for vote in userVotesPre {
            var thisid = vote.value(forKeyPath: "id") as! String;
            if(dealDict[thisid] == nil){
                vHelp.deleteVote(id: thisid);
            }
        }
        
        LH.setDelegate()
        

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.updateVoteCheck();
        
        self.userVotesPre = vHelp.getVotes()
        
        for voteObj in userVotesPre {
            userVotes[voteObj.value(forKeyPath: "id") as! String] = voteObj.value(forKeyPath: "vote") as! Int16
        }
        
        tableView.reloadData()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.searchController.searchBar.text! != ""){
            return filteredDeals.count
        } else if deals.count == 0 {
            return 1;
        } else {
            return deals.count;
        }
    }

    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DealCell", for: indexPath as IndexPath)
            as! DealCell
        
        
        if (deals.count == 0){
            
            if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse){
                cell.nameLabel.text = "No deals found."
                cell.locatLabel.text = "Tap '+' to add a local deal."
                
            } else {
                cell.nameLabel.text = "Location access not granted."
                cell.locatLabel.text = "Access can be granted in Settings."
            }
            
            cell.priceLabel.isHidden = true
            cell.scoreLabel.isHidden = true
            cell.upVote.isHidden = true
            cell.downVote.isHidden = true
            cell.accessoryType = .none
            
        }
            
            
        else {
            
            var object = deals[(indexPath as NSIndexPath).row]
            
            if(self.searchController.searchBar.text! != ""){
                object = filteredDeals[(indexPath as NSIndexPath).row]
            }

            cell.priceLabel.isHidden = false
            cell.scoreLabel.isHidden = false
            cell.upVote.isHidden = false
            cell.downVote.isHidden = false
            cell.nameLabel.text = object.name
            cell.locatLabel.text = object.locat
            cell.score = object.score
            cell.scoreLabel.text = "\(object.score)"
            cell.priceLabel.text = "$\(object.priceString)"
            cell.productImage.image = object.image
            cell.idS = object.id
            
            if let voteIndex = userVotes[object.id] {

                if(voteIndex == 1){
                    let imageU = UIImage(named: "up-arrow-3")?.withRenderingMode(.alwaysTemplate)
                    cell.upVote.setImage(imageU, for: .normal)
                    cell.upVote.tintColor = accG
                    cell.voted = 1
                    let imageD = UIImage(named: "down-arrow-2")?.withRenderingMode(.alwaysTemplate)
                    cell.downVote.setImage(imageD, for: .normal)
                    cell.downVote.tintColor = accR
                } else if(voteIndex == -1){
                    let imageU = UIImage(named: "up-arrow-2")?.withRenderingMode(.alwaysTemplate)
                    cell.upVote.setImage(imageU, for: .normal)
                    cell.upVote.tintColor = accG
                    let imageD = UIImage(named: "down-arrow-3")?.withRenderingMode(.alwaysTemplate)
                    cell.downVote.setImage(imageD, for: .normal)
                    cell.downVote.tintColor = accR
                }
                
                
                
            }

        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "dealDetail"){
            
            let selectedIndex = tableView.indexPathForSelectedRow?.row
            let sDeal = deals[selectedIndex!]

            
            let selectName = sDeal.name
            let selectPrice = sDeal.price
            let selectPriceString = sDeal.priceString
            let selectNotes = sDeal.notes
            let selectLocat = sDeal.locat
            let selectLong = sDeal.long
            let selectLat = sDeal.lat
            let selectScore = sDeal.score
            let selectImage = sDeal.image
            let selectID = sDeal.id
            
            
            var dvc = segue.destination as! UINavigationController
            let tc = dvc.topViewController as! DealDetailViewController
            
            tc.dName = selectName;
            tc.dPrice = selectPrice;
            tc.dPriceString = selectPriceString;
            tc.dNotes = selectNotes;
            tc.dLocat = selectLocat;
            tc.dLong = selectLong;
            tc.dLat = selectLat;
            tc.dScore = selectScore;
            tc.dImage = selectImage;
            tc.dID = selectID;
            
        
        } else if(segue.identifier == "newDealAdded"){
            addedDeal = true;
            model.delegate = self
        } else if(segue.identifier == "cancelToHome"){
            addedDeal = false;
        } else if(segue.identifier == "doneWithDetail"){
            model.delegate = self

        }
    }
    
    

    @IBAction func refreshTable(_ sender: Any) {
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse){
            
            LH.getrefreshLocation()
                
            alert = UIAlertController(title: nil, message: "Refreshing...", preferredStyle: .alert)
                
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
                
            alert.view.addSubview(loadingIndicator)
            present(alert, animated: true, completion: nil)
            
            
        } else {
        
            self.alert.dismiss(animated: false, completion: {
            
                var message = "Location access is required for CampusDeals to function properly. Please go to Settings and allow location access for CampusDeals."
                let alertController = UIAlertController(title: "Location Access",
                                                        message: message,
                                                        preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                self.present(alertController, animated: true)

            })
            
        }
        
    }
    
    
    func updateVoteCheck(){
        
        if(changeID != ""){
            
            deals[selectedIndex!].score = self.changeScore;
            
        }
        
    }
    
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {}
    
    
    func updateSearchResults(for searchController: UISearchController) {
        let cancelButtonSearchButton = searchController.searchBar.value(forKeyPath: "cancelButton") as? UIButton
        cancelButtonSearchButton?.setTitle("Cancel", for: .normal)
        cancelButtonSearchButton?.setTitleColor(UIColor.white, for: .normal)

        
        self.filteredDeals = deals.filter { deal in
            return deal.name.lowercased().contains(self.searchController.searchBar.text!.lowercased())
        }
        tableView.reloadData()
    }

    
}

extension AllDealsTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}


extension AllDealsTableViewController: LocationHelperDelegate {
    
    func locationFound(latIn: Double, lonIn: Double) {
        tableView.reloadData()
        print(latIn, lonIn)
        self.currentLatitude = latIn;
        self.currentLongitude = lonIn;
        
        let userLocation = CLLocation(latitude: self.currentLatitude, longitude: self.currentLongitude)
            
        alert = UIAlertController(title: nil, message: "Loading Deals", preferredStyle: .alert)
            
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
            
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
            
        CloudKitModel.sharedInstance.fetchDeals(userLocation, radiusInMeters: 12874.8)

    }
    
    
    func refreshFound(latIn: Double, lonIn: Double) {
        print(latIn, lonIn)
        self.currentLatitude = latIn;
        self.currentLongitude = lonIn;
        
        let userLocation = CLLocation(latitude: self.currentLatitude, longitude: self.currentLongitude)
        
        CloudKitModel.sharedInstance.refresh(userLocation, radiusInMeters: 12874.8)
        
    }
    
    
    func locationDenied(){
        
        self.dismiss(animated: false, completion: {
        
            var message = "Location access is required for CampusDeals to function properly. Please go to Settings and allow location access for CampusDeals."
            let alertController = UIAlertController(title: "Location Access",
                                                    message: message,
                                                    preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alertController, animated: true)
        
        })
        
        
    }
    
    func locationAllowed(){
    
    
    
    }

}


// MARK: - ModelDelegate
extension AllDealsTableViewController: CloudKitModelDelegate {
    
    func modelUpdated() {
        refreshControl?.endRefreshing()
        self.dismiss(animated: false, completion: nil)
        gData = true
        addedDeal = true
        icloud = true
        tableView.reloadData()
    }
    
    func refreshDone(){
        refreshControl?.endRefreshing()
        self.dismiss(animated: false, completion: nil)
        
        self.userVotesPre.removeAll()
        self.userVotes.removeAll()
        
        self.userVotesPre = vHelp.getVotes()
        
        for voteObj in userVotesPre {
            userVotes[voteObj.value(forKeyPath: "id") as! String] = voteObj.value(forKeyPath: "vote") as! Int16
        }

        for vote in userVotesPre {
            var thisid = vote.value(forKeyPath: "id") as! String;
            if(dealDict[thisid] == nil){
                vHelp.deleteVote(id: thisid);
            }
        }
        
        icloud = true;
        
        addedDeal = false
        tableView.reloadData()
    }
    
    
    func errorUpdating(_ error: NSError) {
        
        self.alert.dismiss(animated: false, completion: {
        
            let message: String
            let title: String
            if error.code == 1 {
                message = "Log into iCloud on your device for full CampusDeals functionality."
                title = "iCloud Required"
            } else {
                message = error.localizedDescription
                title = "Error"
            }
            
            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)

            
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            

            self.present(alertController, animated: true)
            
        
        })
        
        
    }
    
    
    func noIcloud(){
        self.dismiss(animated: false, completion: {
        
            var message = "Log into iCloud on your device for full CampusDeals functionality."
            let alertController = UIAlertController(title: "iCloud Required",
                                                    message: message,
                                                    preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alertController, animated: true)
        
        })
        
    
    }
    
    func locationNotAllowed(){
    
        self.dismiss(animated: false, completion: {
        
            var message = "Location access is required for CampusDeals to function properly. Please go to Settings and allow location access for CampusDeals."
            let alertController = UIAlertController(title: "Location Access",
                                                    message: message,
                                                    preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alertController, animated: true)
        
        })
        
    
    }
    
    
}


























