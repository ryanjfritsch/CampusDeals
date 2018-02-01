//
//  DealCell.swift
//  Drinks
//
//  Created by Ryan Fritsch on 6/13/15.
//  Copyright (c) 2015 Ryan Fritsch. All rights reserved.
//

import UIKit

class DealCell: UITableViewCell{
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locatLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var upVote: UIButton!
    @IBOutlet weak var downVote: UIButton!
    
    @IBOutlet weak var productImage: UIImageView!
    
    var idS = ""
    var onB = false
    var score = 0;
    var voted = 0;

    
    let accG = UIColor(red: 36/255, green: 108/255, blue: 0/255, alpha: 1.0)
    let accR = UIColor(red: 212/255, green: 6/255, blue: 0/255, alpha: 1.0)
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        
        
        let imageU = UIImage(named: "up-arrow-2")?.withRenderingMode(.alwaysTemplate)
        upVote.setImage(imageU, for: .normal)
        upVote.tintColor = accG
        
        let imageD = UIImage(named: "down-arrow-2")?.withRenderingMode(.alwaysTemplate)
        downVote.setImage(imageD, for: .normal)
        downVote.tintColor = accR

        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    @IBAction func upVoteTapped(_ sender: Any) {
        
        
        if(voted == 0){
            
            let imageU = UIImage(named: "up-arrow-3")?.withRenderingMode(.alwaysTemplate)
            upVote.setImage(imageU, for: .normal)
            upVote.tintColor = accG
            
            let imageD = UIImage(named: "down-arrow-2")?.withRenderingMode(.alwaysTemplate)
            downVote.setImage(imageD, for: .normal)
            downVote.tintColor = accR
            
            score = Int(scoreLabel.text!)!
            
            voted = 1
            score = score + 1;
            scoreLabel.text = "\(self.score)"
            
            var foundIndex = -1;
            for i in 0...(deals.count-1) {
                if(deals[i].id == idS){
                    foundIndex = i;
                }
            }
            if(foundIndex != -1){ deals[foundIndex].score = self.score }
            
            var ckm = CloudKitModel()
            ckm.updateDeal(dealID: idS, vote: 1)
            
            var vH = UserDataHelper()
            vH.saveVote(idIn: idS, voteIn: 1)
        
        } else if(voted == -1){
            
            let imageU = UIImage(named: "up-arrow-3")?.withRenderingMode(.alwaysTemplate)
            upVote.setImage(imageU, for: .normal)
            upVote.tintColor = accG
            
            let imageD = UIImage(named: "down-arrow-2")?.withRenderingMode(.alwaysTemplate)
            downVote.setImage(imageD, for: .normal)
            downVote.tintColor = accR
            
            score = Int(scoreLabel.text!)!
            
            voted = 1
            score = score + 2;
            scoreLabel.text = "\(self.score)"
            
            var foundIndex = -1;
            for i in 0...(deals.count-1) {
                if(deals[i].id == idS){
                    foundIndex = i;
                }
            }
            if(foundIndex != -1){ deals[foundIndex].score = self.score }
            
            var ckm = CloudKitModel()
            ckm.updateDeal(dealID: idS, vote: 2)
            
            var vH = UserDataHelper()
            vH.editVote(id: idS, newVote: 1)
        
        }

        
    }
    

    @IBAction func downVoteTapped(_ sender: Any) {
        
        if(voted == 0){
        
            let imageU = UIImage(named: "up-arrow-2")?.withRenderingMode(.alwaysTemplate)
            upVote.setImage(imageU, for: .normal)
            upVote.tintColor = accG
            
            let imageD = UIImage(named: "down-arrow-3")?.withRenderingMode(.alwaysTemplate)
            downVote.setImage(imageD, for: .normal)
            downVote.tintColor = accR
            
            score = Int(scoreLabel.text!)!
            
            voted = -1
            score = score - 1;
            scoreLabel.text = "\(self.score)"
            
            var foundIndex = -1;
            for i in 0...(deals.count-1) {
                if(deals[i].id == idS){
                    foundIndex = i;
                }
            }
            if(foundIndex != -1){ deals[foundIndex].score = self.score }
            
            var ckm = CloudKitModel()
            ckm.updateDeal(dealID: idS, vote: -1)
            
            var vH = UserDataHelper()
            vH.saveVote(idIn: idS, voteIn: -1)
            
            
        
        } else if(voted == 1){
            
            let imageU = UIImage(named: "up-arrow-2")?.withRenderingMode(.alwaysTemplate)
            upVote.setImage(imageU, for: .normal)
            upVote.tintColor = accG
            
            let imageD = UIImage(named: "down-arrow-3")?.withRenderingMode(.alwaysTemplate)
            downVote.setImage(imageD, for: .normal)
            downVote.tintColor = accR
        
            score = Int(scoreLabel.text!)!
            
            voted = -1
            score = score - 2;
            scoreLabel.text = "\(self.score)"
            
            var foundIndex = -1;
            for i in 0...(deals.count-1) {
                if(deals[i].id == idS){
                    foundIndex = i;
                }
            }
            if(foundIndex != -1){ deals[foundIndex].score = self.score }
            
            var ckm = CloudKitModel()
            ckm.updateDeal(dealID: idS, vote: -2)
            
            var vH = UserDataHelper()
            vH.editVote(id: idS, newVote: -1)
        
        }
        
        
    }
    
    

}









