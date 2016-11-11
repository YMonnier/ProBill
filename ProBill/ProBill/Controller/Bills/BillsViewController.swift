//
//  BillsViewController.swift
//  ProBill
//
//  Created by Ysée Monnier on 29/04/16.
//  Copyright © 2016 MONNIER Ysee. All rights reserved.
//

import UIKit
import CoreData

class BillsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    //CollectionView
    @IBOutlet weak var collectionView: UICollectionView!
    let reuseIdentifierCell = "BillCell"
    let reuseIdentifierHeader = "BillHeader"
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var billSegue: Bill? = nil
    
    //Data
    var data: [SubCategory] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        
        //register nib view
        self.collectionView!.register(UINib(nibName: "BillCell", bundle: Bundle(for: BillsViewController.self )), forCellWithReuseIdentifier: reuseIdentifierCell)
        self.collectionView!.register(UINib(nibName: "BillHeader", bundle: Bundle(for: BillsViewController.self )), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseIdentifierHeader)
        
        //Load data...
        self.loadData()
        
        //Layout creation
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.headerReferenceSize = CGSize(width: 100,height: 60)
        self.collectionView.collectionViewLayout = layout
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadData()
        self.collectionView.reloadData()
    }
    
    //MARK:- Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(#function)
        if segue.identifier == "DetailSegue" {
            let destinationController = segue.destination as! BillDetailViewController
            destinationController.bill = self.billSegue
        }
    }
    
    //MARK: Action
    
    @IBAction func editAction(_ sender: AnyObject) {
        
    }
    
    
    //MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print(#function)
        print(self.data.count)
        return self.data.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(#function)
        print(self.data[section].bills.count)
        return self.data[section].bills.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierCell, for: indexPath) as! BillCellView
        let bill: Bill = Array(self.data[indexPath.section].bills)[indexPath.row]
        //cell.backgroundColor = UIColor.clearColor()
        
        cell.picture.image = UIImage(data: (bill.pictures.first?.image)! as Data)
        cell.price.text = String(bill.price) + " Zl"
        cell.date.text = bill.date.toString("yyyy-MM-dd")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.billSegue = Array(self.data[indexPath.section].bills)[indexPath.row]
        self.performSegue(withIdentifier: "DetailSegue", sender: self)
        self.searchBar.showsCancelButton = false
        self.searchBar.resignFirstResponder()
        self.searchBar.text = ""
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    {
        
        let rect = UIScreen.main.bounds
        let screenWidth = rect.size.width - 40
        return CGSize(width: screenWidth/3, height: 160);
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader && !self.data[indexPath.section].bills.isEmpty {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseIdentifierHeader, for: indexPath) as! BillHeaderView
            header.title.text = self.data[(indexPath as NSIndexPath).section].name
            return header;
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(10, 5, 10, 5); //top,left,bottom,right
    }
    
    //MARK: - Search control
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(#function)
        autoreleasepool {
            var predicate: NSPredicate? = nil
            var error: NSError? = nil
            var result: [AnyObject]?
            
            if self.searchBar.text?.characters.count != 0 {
                predicate = NSPredicate(format: "(name contains [cd] %@)", searchBar.text!)
            }
            
            let fetch = NSFetchRequest<SubCategory>(entityName: "SubCategory")
            fetch.predicate = predicate
            do {
                result = try self.managedObjectContext!.fetch(fetch)
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
    
    // called when cancel button pressed
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print(#function)
        self.searchBar.showsCancelButton = false
        self.searchBar.resignFirstResponder()
        self.searchBar.text = ""
        self.loadData()
    }
    
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchBar.showsCancelButton = true
        return true
    }
    
    
    //MARK: - LoadData
    fileprivate func loadData() {
        autoreleasepool {
            var error: NSError? = nil
            var result: [AnyObject]?
            
            let fetch = NSFetchRequest<SubCategory>(entityName: "SubCategory")
            do {
                result = try self.managedObjectContext!.fetch(fetch)
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
