//
//  BillsViewController.swift
//  ProBill
//
//  Created by Ysée Monnier on 29/04/16.
//  Copyright © 2016 MONNIER Ysee. All rights reserved.
//

import UIKit
import CoreData

class BillsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //CollectionView
    @IBOutlet weak var collectionView: UICollectionView!
    let reuseIdentifierCell = "BillCell"
    let reuseIdentifierHeader = "BillHeader"
    
    var managedObjectContext: NSManagedObjectContext? = nil

    //Data
    var data: [SubCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        //register nib view
        self.collectionView!.registerNib(UINib(nibName: "BillCell", bundle: NSBundle(forClass: BillsViewController.self )), forCellWithReuseIdentifier: reuseIdentifierCell)
        self.collectionView!.registerNib(UINib(nibName: "BillHeader", bundle: NSBundle(forClass: BillsViewController.self )), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseIdentifierHeader)
        
        //Load data...
        self.loadData()
        
        //Layout creation
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.headerReferenceSize = CGSizeMake(100,60)
        self.collectionView.collectionViewLayout = layout
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadData()
        self.collectionView.reloadData()
    }
    
    //MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        print(#function)
        print(self.data.count)
        return self.data.count
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(#function)
        print(self.data[section].bills.count)
        return self.data[section].bills.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifierCell, forIndexPath: indexPath) as! BillCellView
        let bill: Bill = Array(self.data[indexPath.section].bills)[indexPath.row]
        //cell.backgroundColor = UIColor.clearColor()

        cell.picture.image = UIImage(data: bill.picture)
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        
        let rect = UIScreen.mainScreen().bounds
        let screenWidth = rect.size.width - 40
        return CGSizeMake(screenWidth/3, 160);
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(10, 5, 10, 5); //top,left,bottom,right
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        print("ICI")
        if kind == UICollectionElementKindSectionHeader && !self.data[indexPath.section].bills.isEmpty {
            let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: reuseIdentifierHeader, forIndexPath: indexPath) as! BillHeaderView
            header.title.text = self.data[indexPath.section].name
            return header;
        }
        print("ONONONON")
        return UICollectionReusableView()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! BillCellView
    }
    
    //MARK: - LoadData
    private func loadData() {
        autoreleasepool {
            var error: NSError? = nil
            var result: [AnyObject]?
            
            let fetch: NSFetchRequest = NSFetchRequest(entityName: "SubCategory")
            
            do {
                result = try self.managedObjectContext!.executeFetchRequest(fetch)
            } catch let nserror1 as NSError{
                error = nserror1
                result = nil
            }
            if result != nil {
                self.data = []
                self.data = (result as! [SubCategory]).filter({ (sc) -> Bool in
                    !sc.bills.isEmpty
                })
                
                
            }
        }
    }
}