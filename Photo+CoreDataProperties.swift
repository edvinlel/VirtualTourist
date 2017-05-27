//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Edvin Lellhame on 5/21/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var image: NSData?
    @NSManaged public var media_url: String?
    @NSManaged public var currentPage: Int32
    @NSManaged public var maxPages: Int32
    @NSManaged public var pin: Pin?

}
