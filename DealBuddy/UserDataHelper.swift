//
//  UserDataHelper.swift
//  DealBuddy
//
//  Created by Ryan Fritsch on 4/20/17.
//  Copyright © 2017 Ryan Fritsch. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class UserDataHelper {
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    func getVotes() -> [NSManagedObject] {
        
        var allVotes: [NSManagedObject] = []
        
        var fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "UserVoteCore")
        
        
        //3
        do {
            allVotes = try managedObjectContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return allVotes;
        
        
    }
    
    
    func editVote(id: String, newVote: Int16){
        
        let voteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "UserVoteCore");
        voteFetch.predicate = NSPredicate(format: "id == %@", id)
        
        
        do {
            let fetchedVotes = try managedObjectContext.fetch(voteFetch) as! [UserVoteCore]
            fetchedVotes[0].vote = newVote;
            
            try self.managedObjectContext.save();
        } catch {
            fatalError("Failed to save votes: \(error)")
        }
        
        
        
        
        
    }
    
    
    
    func saveVote(idIn: String, voteIn: Int16){
        
        let ent = NSEntityDescription.entity(forEntityName: "UserVoteCore", in: self.managedObjectContext)
        
        let voteObj = UserVoteCore(entity: ent!, insertInto: managedObjectContext)
        
        voteObj.id = idIn
        voteObj.vote = voteIn
        
        
        
        do {
            try self.managedObjectContext.save();
            
        } catch _ {
            print("ERROR");
        }
        
        
    }
    
    
    func deleteVote(id: String){
        
        let voteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "UserVoteCore");
        voteFetch.predicate = NSPredicate(format: "id == %@", id)
        
        if let result = try? managedObjectContext.fetch(voteFetch) {
            for object in result {
                managedObjectContext.delete(object as! NSManagedObject)
            }
        }
        
    }
    
}




















