//
//  SubCategoriesViewController.swift
//  ProBill
//
//  Created by Ysée Monnier on 29/04/16.
//  Copyright © 2016 MONNIER Ysee. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SubCategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var category: Category?
    var managedObjectContext: NSManagedObjectContext? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Delete useless separator cell
        //self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        //Title
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 440, height: 44))
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.center
        label.text = self.category!.name + "\nSub Category"
        self.navigationItem.titleView = label
        
        self.managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(SubCategoriesViewController.insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
     dismiss inputView when user touch outside the view
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.searchBar.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func insertNewObject(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Sub Categories", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Your sub category"
            textField.autocapitalizationType = .sentences
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            let subCategory = textField.text
            let context = self.fetchedResultsController.managedObjectContext
            let entity = self.fetchedResultsController.fetchRequest.entity!
            let newManagedObject = NSEntityDescription.insertNewObject(forEntityName: entity.name!, into: context) as! SubCategory
            newManagedObject.name = subCategory!
            newManagedObject.category = self.category!
            
            // Save the context.
            do {
                try context.save()
            } catch {
                abort()
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - TableView Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.fetchedResultsController.sections![0].numberOfObjects)
        return self.fetchedResultsController.sections![0].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print((indexPath as NSIndexPath).row)
        let cell: CategoriesCellView = tableView.dequeueReusableCell(withIdentifier: "CatCell") as! CategoriesCellView
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath) as! NSManagedObject)
            do {
                try context.save()
            } catch {
                abort()
            }
        }
    }
    
    
    fileprivate func configureCell(_ cell: CategoriesCellView, atIndexPath indexPath: IndexPath) {
        let object: SubCategory = self.fetchedResultsController.object(at: indexPath) as! SubCategory
        cell.name.text = "\(object.name)"
    }
    
    //MARK:- Search Control
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(#function)
        var predicate: NSPredicate? = NSPredicate(format: "category.name = %@", self.category!.name)
        
        if self.searchBar.text?.characters.count != 0 {
            predicate = NSPredicate(format: "category.name = %@ && (name contains [cd] %@)", self.category!.name, searchBar.text!)
        }
        self.fetchedResultsController.fetchRequest.predicate = predicate
        do {
            try self.fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error \(object_getClass(self)) \(#function) : \(error.debugDescription))")
        }
        
        tableView.reloadData()
    }
    
    // called when cancel button pressed
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print(#function)
        self.searchBar.showsCancelButton = false
        self.searchBar.resignFirstResponder()
        self.searchBar.text = ""
        fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "category.name = %@", self.category!.name)
        do {
            try self.fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error \(object_getClass(self)) \(#function) : \(error.debugDescription))")
        }
        tableView.reloadData()
    }
    
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchBar.showsCancelButton = true
        return true
    }
    
    //MARK:- Fetch Control
    
    var fetchedResultsController: NSFetchedResultsController<SubCategory> {
        if self._fetchedResultsController != nil {
            return self._fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest<SubCategory>()
        let entity = NSEntityDescription.entity(forEntityName: "SubCategory", in: self.managedObjectContext!)
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "category.name = %@", self.category!.name)
        
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "name", cacheName: nil)
        aFetchedResultsController.delegate = self
        self._fetchedResultsController = aFetchedResultsController
        
        do {
            try self._fetchedResultsController!.performFetch()
        } catch {
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        return self._fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<SubCategory>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .left)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.configureCell(tableView.cellForRow(at: indexPath!)! as! CategoriesCellView, atIndexPath: indexPath!)
        case .move:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }   
}
