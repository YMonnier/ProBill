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
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var overlay: UIView!
    
    var currentPictureIndex: Int = 0
    
    var pictures: [Picture]?
    var bill: Bill?
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        self.managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        
        //Overlay
        let bColor = UIColor.black.withAlphaComponent(0.5)
        self.overlay.backgroundColor = bColor
        self.commentTextView.backgroundColor = UIColor.clear
        
        //Title
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 440, height: 44))
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.center
        print("1")
        label.text = "Detail\n\(self.bill!.subCategory.name)"
        print("2")
        self.navigationItem.titleView = label
        
        //Actions button
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(BillDetailViewController.deleteObject(_:)))
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(BillDetailViewController.shareObject(_:)))
        self.navigationItem.rightBarButtonItems = [trashButton, shareButton]
        
        //Swipe pictures
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(BillDetailViewController.respondToSwipeGesture(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(BillDetailViewController.respondToSwipeGesture(_:)))
        swipeDown.direction = .left
        self.view.addGestureRecognizer(swipeDown)
        
        if let bill = self.bill {
            print(bill)
            //Page Control
            self.pageControl.numberOfPages = bill.pictures.count
            self.pageControl.currentPage = self.currentPictureIndex
            self.pageControl.transform = CGAffineTransform(scaleX: 1.15, y: 1.15);
            self.pictures = Array(bill.pictures)
            
            //Put data into UI
            self.commentTextView.text = bill.comment
            if let pic = pictures?.first {
                self.picture.image = UIImage(data: pic.image)
            }
            self.price.text = String(bill.price) + " Zl"
            self.picture.image = UIImage(data:(self.pictures?[0].image)! as Data)
            self.date.text = bill.date.toString("yyyy/MM/dd")
        }
        print(#function)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Action
    
    func deleteObject(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Your Bill", message: "Are you sure to delete this bill?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            self.managedObjectContext!.delete(self.bill!)
            do {
                try self.managedObjectContext!.save()
            } catch let error as NSError {
                print("Error \(object_getClass(self)) \(#function) : \(error.debugDescription))")
            }
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func shareObject(_ sender: AnyObject) {
        //TODO...
    }
    
    //MARK: Swipe picture
    
    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                self.currentPictureIndex = self.currentPictureIndex + 1 == self.pictures?.count ? 0 : self.currentPictureIndex + 1
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                self.currentPictureIndex = self.currentPictureIndex - 1 == -1 ? self.pictures!.count - 1 : self.currentPictureIndex - 1
            default:
                break
            }
            self.pageControl.currentPage = self.currentPictureIndex
            self.picture.image = UIImage(data:(self.pictures![self.currentPictureIndex].image) as Data)
        }
    }
}
