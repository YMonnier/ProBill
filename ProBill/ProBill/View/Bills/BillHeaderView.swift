//
//  BillHeaderView.swift
//  ProBill
//
//  Created by Ysée Monnier on 30/04/16.
//  Copyright © 2016 MONNIER Ysee. All rights reserved.
//

import Foundation
import UIKit

class BillHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = PBColor.lightYellow
        self.title.textColor = UIColor.blackColor()
    }
}
