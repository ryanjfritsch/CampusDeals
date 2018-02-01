//
//  AddDeal.swift
//  DealBuddy
//
//  Created by Ryan Fritsch on 4/17/17.
//  Copyright © 2017 Ryan Fritsch. All rights reserved.
//

import UIKit

class AddDeal: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var dealNameField: UITextField!
    @IBOutlet weak var dealDescrField: UITextField!
    @IBOutlet weak var dealPriceField: UITextField!
    @IBOutlet weak var dealLocationButton: UIButton!
    @IBOutlet weak var selectedImageView: UIImageView!
    
    @IBOutlet weak var nameCell: UITableViewCell!
    @IBOutlet weak var descrCell: UITableViewCell!
    @IBOutlet weak var priceCell: UITableViewCell!
    @IBOutlet weak var locationCell: UITableViewCell!
    @IBOutlet weak var imageCell: UITableViewCell!
    
    let model: CloudKitModel = CloudKitModel.sharedInstance
    
    let defaultBlue = UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1)
    
    var selectedImage: UIImage!;
    
    var foundStreetAddress = "Select Location";
    var foundLongitude = 0.0;
    var foundLatitude = 0.0;
    
    
    let accG = UIColor(red: 36/255, green: 108/255, blue: 0/255, alpha: 1.0)
    let accR = UIColor(red: 212/255, green: 6/255, blue: 0/255, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let graytb = UIColor(red: 40/255, green: 40/255, blue: 44/255, alpha: 1.0)
        
        navigationController!.navigationBar.barTintColor = graytb
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddDeal.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        dealNameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        dealPriceField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)


        model.delegate = self

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.dealLocationButton.setTitleColor(defaultBlue, for:.normal)
        self.dealLocationButton.setTitle(foundStreetAddress, for:.normal)
        
        locationCell.layer.borderWidth = 0.0
        
    }
    
    
    
    @IBAction func cancelToAddDealViewController(segue:UIStoryboardSegue) {}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    @IBAction func submitDeal(_ sender: Any) {
        
        let myRed : UIColor = UIColor.red
        let myGrey: UIColor = UIColor.lightGray
        
        
        if(dealNameField.text == "" || dealPriceField.text == "" || dealLocationButton.titleLabel?.text == "" || selectedImageView.image == nil)
        {
            if(dealNameField.text == ""){
                self.nameCell.layer.borderWidth = 1.0
                self.nameCell.layer.borderColor = myRed.cgColor
            } else {
                self.nameCell.layer.borderWidth = 0.0
                self.nameCell.layer.borderColor = myGrey.cgColor
            }
            
            if(dealPriceField.text == ""){
                self.priceCell.layer.borderWidth = 1.0
                self.priceCell.layer.borderColor = myRed.cgColor
            } else {
                self.priceCell.layer.borderWidth = 0.0
                self.priceCell.layer.borderColor = myGrey.cgColor
            }
            
            if(dealLocationButton.titleLabel?.text == "Select Location"){
                self.locationCell.layer.borderWidth = 1.0
                self.locationCell.layer.borderColor = myRed.cgColor
                
            } else {
                self.locationCell.layer.borderWidth = 0.0
                self.locationCell.layer.borderColor = myGrey.cgColor
            }
            
            if(selectedImageView.image == nil){
                self.imageCell.layer.borderWidth = 1.0
                self.imageCell.layer.borderColor = myRed.cgColor
                
            } else {
                self.imageCell.layer.borderWidth = 0.0
                self.imageCell.layer.borderColor = myGrey.cgColor
            }
        
        
        } else {
        
            var checkDouble: Double!
            checkDouble = Double(dealPriceField.text!)
            
            if(checkDouble == nil || checkDouble < 0.0)
            {
                let alertController = UIAlertController(title: "Input Error", message: "Price must be a positive number. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    print("OK")
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            } else {
                
                if(icloud){
                    
                    CloudKitModel.sharedInstance.saveNewDeal(name: dealNameField.text!, price: checkDouble, description: dealDescrField.text!, address: (dealLocationButton.titleLabel?.text)!, latitude: foundLatitude, longitude: foundLongitude, image: selectedImageView.image!)
                    
                    
                    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
                    
                    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                    loadingIndicator.hidesWhenStopped = true
                    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                    loadingIndicator.startAnimating();
                    
                    alert.view.addSubview(loadingIndicator)
                    present(alert, animated: true, completion: nil)

                } else {
                
                    var message = "You must be logged into iCloud on your device to submit a deal. If you are logged into iCloud and still get this message, please restart CampusDeals and try again."
                    let alertController = UIAlertController(title: "iCloud Required",
                                                            message: message,
                                                            preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(alertController, animated: true)

                }
                    
                
            }
            
        }
        
        
    }
   
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @IBAction func imagePicker(_ sender: Any) {
        
        let photoPicker = UIImagePickerController ()
        photoPicker.delegate = self
        photoPicker.sourceType = .photoLibrary
        self.present(photoPicker, animated: true, completion: nil)
        
    }

    @IBAction func cameraPicker(_ sender: Any) {
        
        let photoPicker = UIImagePickerController ()
        photoPicker.delegate = self
        photoPicker.sourceType = .camera
        self.present(photoPicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        
        picker.dismiss(animated: true, completion: nil)
        
        var selectedImageOrig = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        var w = selectedImageOrig?.size.width
        var h = selectedImageOrig?.size.height
        
        w = w! / 2
        h = h! / 2
        
        selectedImage = self.resizeImage(image: selectedImageOrig!, targetSize: CGSize(width: w!, height: h!))

        
        selectedImageView.image = selectedImage
        selectedImageView.backgroundColor = UIColor.white
        
        imageCell.layer.borderWidth = 0.0;
        
    }
    
    
    func textFieldDidChange(_ textField: UITextField) {
        
        if(textField == dealNameField){
            nameCell.layer.borderWidth = 0.0
        } else if(textField == dealPriceField){
            priceCell.layer.borderWidth = 0.0
        }
        
        
    }

    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    
}


// MARK: - ModelDelegate
extension AddDeal: CloudKitModelDelegate {
    
    func modelUpdated() {
        
        self.dismiss(animated: false, completion: nil)
        
        let alert = UIAlertController(title: nil, message: "Success", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 45, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.dismiss(animated: false, completion: {
                self.performSegue(withIdentifier: "newDealAdded", sender: self)
            })
            
        }
    }
    
    func refreshDone() {
        refreshControl?.endRefreshing()
        
    }
    
    func errorUpdating(_ error: NSError) {
        let message: String
        if error.code == 1 {
            message = "Log into iCloud on your device and make sure the iCloud drive is turned on for this app."
        } else {
            message = error.localizedDescription
        }
        let alertController = UIAlertController(title: nil,
                                                message: message,
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func noIcloud() {
        //
    }
    
    func locationNotAllowed(){
        
        self.dismiss(animated: false, completion: nil)
        var message = "Location access is required for CampusDeals to function properly. Please go to Settings and allow location access for CampusDeals."
        let alertController = UIAlertController(title: nil,
                                                message: message,
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
        
        
    }

    
}




















