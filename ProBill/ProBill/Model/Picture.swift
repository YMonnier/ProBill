//
//  Picture.swift
//  ProBill
//
//  Created by Ysée Monnier on 06/05/16.
//  Copyright © 2016 MONNIER Ysee. All rights reserved.
//

import Foundation
import CoreData

@objc(Picture)
class Picture: NSManagedObject {
    @NSManaged var image: NSData
    @NSManaged var bill: Bill
}