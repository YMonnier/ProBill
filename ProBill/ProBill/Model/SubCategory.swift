//
//  SubCategory.swift
//  ProBill
//
//  Created by Ysée Monnier on 29/04/16.
//  Copyright © 2016 MONNIER Ysee. All rights reserved.
//

import Foundation
import CoreData

@objc(SubCategory)
class SubCategory: NSManagedObject {
    //@NSManaged var id: Int
    @NSManaged var name: String
    @NSManaged var category: Category
    @NSManaged var bills: Set<Bill>
}