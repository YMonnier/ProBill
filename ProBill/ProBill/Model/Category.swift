//
//  Category.swift
//  ProBill
//
//  Created by Ysée Monnier on 29/04/16.
//  Copyright © 2016 MONNIER Ysee. All rights reserved.
//

import Foundation
import CoreData

@objc(Category)
class Category: NSManagedObject {
    //@NSManaged var id: Int
    @NSManaged var name: String
    //@NSManaged var sex: [String]
    @NSManaged var subCategories: Set<SubCategory>
}