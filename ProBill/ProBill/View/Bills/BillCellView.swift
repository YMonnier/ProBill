//
//  BillCellView.swift
//  ProBill
//
//  Created by Ysée Monnier on 30/04/16.
//  Copyright © 2016 MONNIER Ysee. All rights reserved.
//

import Foundation
import UIKit

class BillCellView: UICollectionViewCell{
    @IBOutlet weak var picture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 2
        self.layer.borderColor = PBColor.blue.CGColor
        self.layer.cornerRadius = 10
    }
}