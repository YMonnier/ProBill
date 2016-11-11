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
    
    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 2
        self.layer.borderColor = PBColor.gray.cgColor
        self.layer.cornerRadius = 10
        
        self.overlay.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    }
}
