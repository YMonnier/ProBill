//
//  GlobalExtension.swift
//  ProBill
//
//  Created by Ysée Monnier on 30/04/16.
//  Copyright © 2016 MONNIER Ysee. All rights reserved.
//

import Foundation
import UIKit

struct PBColor {
    static let yellow = UIColor(red: (255/255), green: (229/255), blue: (51/255), alpha: 1.0)
    static let blue = UIColor(red: (79/255), green: (172/255), blue: (255/255), alpha: 1.0)
    static let orange = UIColor(red: (222/255), green: (138/255), blue: (0/255), alpha: 1.0)
    static let gray = UIColor(red: (74/255), green: (74/255), blue: (74/255), alpha: 1.0)
}

extension UIViewController {
    func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}