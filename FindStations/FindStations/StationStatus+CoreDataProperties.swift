//
//  StationStatus+CoreDataProperties.swift
//  FindStations
//
//  Created by Cameron Erdogan on 9/28/16.
//  Copyright © 2016 Cameron Erdogan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension StationStatus {

    @NSManaged var num_bikes_available: Int16
    @NSManaged var num_bikes_disabled: Int16
    @NSManaged var num_docks_available: Int16
    @NSManaged var num_docks_disabled: Int16
    @NSManaged var last_reported: Int32
    @NSManaged var is_renting: Bool
    @NSManaged var is_installed: Bool
    @NSManaged var is_returning: Bool
    @NSManaged var id: String?
    @NSManaged var station: Station?

}
