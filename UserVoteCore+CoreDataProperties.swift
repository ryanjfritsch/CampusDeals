//
//  UserVoteCore+CoreDataProperties.swift
//  DealBuddy
//
//  Created by Ryan Fritsch on 4/20/17.
//  Copyright © 2017 Ryan Fritsch. All rights reserved.
//

import Foundation
import CoreData


extension UserVoteCore {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserVoteCore> {
        return NSFetchRequest<UserVoteCore>(entityName: "UserVoteCore")
    }

    @NSManaged public var id: String?
    @NSManaged public var vote: Int16

}
