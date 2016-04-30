//
//  BillDetailViewController.swift
//  ProBill
//
//  Created by Ysée Monnier on 30/04/16.
//  Copyright © 2016 MONNIER Ysee. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class BillDetailViewController: UIViewController {
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var price: UILabel!
    
    var bill: Bill?
    var managedObjectContext: NSManagedObjectContext? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        //Title
        let label = UILabel(frame: CGRectMake(0, 0, 440, 44))
        label.backgroundColor = UIColor.clearColor()
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        label.text = "Detail\n\(self.bill!.subCategory.name)"
        self.navigationItem.titleView = label
        
        //Actions button
        let trashButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: #selector(BillDetailViewController.deleteObject(_:)))
        let shareButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(BillDetailViewController.deleteObject(_:)))
        
        self.navigationItem.rightBarButtonItems = [trashButton, shareButton]
        
        self.picture.image = UIImage(data: self.bill!.picture)
        self.price.text = String(self.bill!.price) + " Zl"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func deleteObject(sender: AnyObject) {
        let alert = UIAlertController(title: "Your Bill", message: "Are you sure to delete this bill?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
            self.managedObjectContext!.deleteObject(self.bill!)
            do {
                try self.managedObjectContext!.save()
            } catch let error as NSError {
                print("Error \(object_getClass(self)) \(#function) : \(error.debugDescription))")
            }
            self.navigationController?.popViewControllerAnimated(true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { (action) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func shareObject(sender: AnyObject) {
        //TODO...
    }
}