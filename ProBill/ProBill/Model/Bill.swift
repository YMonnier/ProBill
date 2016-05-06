//
//  Bill.swift
//  ProBill
//
//  Created by Ysée Monnier on 29/04/16.
//  Copyright © 2016 MONNIER Ysee. All rights reserved.
//

import Foundation
import CoreData

@objc(Bill)
class Bill: NSManagedObject{
    @NSManaged var price: Double
    @NSManaged var picture: NSData
    @NSManaged var date: NSDate
    @NSManaged var comment: String
    @NSManaged var subCategory: SubCategory
    @NSManaged var pictures: Set<Picture>
}