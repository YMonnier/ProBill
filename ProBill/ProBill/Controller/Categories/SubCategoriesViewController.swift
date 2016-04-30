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

class SubCategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var category: Category?
    var managedObjectContext: NSManagedObjectContext? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        self.managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(SubCategoriesViewController.insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func insertNewObject(sender: AnyObject) {
        let alert = UIAlertController(title: "Sub Categories", message: "", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Your sub category"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            print("TEST")
            let textField = alert.textFields![0] as UITextField
            print("TEST")
            let subCategory = textField.text
            print("TEST")
            let context = self.fetchedResultsController.managedObjectContext
            print("TEST")
            let entity = self.fetchedResultsController.fetchRequest.entity!
            print("TEST")
            let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as! SubCategory
            print("TEST")
            newManagedObject.name = subCategory!
            newManagedObject.category = self.category!
            
            // Save the context.
            do {
                try context.save()
            } catch {
                abort()
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - TableView Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.fetchedResultsController.sections![0].numberOfObjects)
        return self.fetchedResultsController.sections![0].numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print(indexPath.row)
        let cell: CategoriesCellView = tableView.dequeueReusableCellWithIdentifier("CatCell") as! CategoriesCellView
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
            do {
                try context.save()
            } catch {
                abort()
            }
        }
    }
    
    
    private func configureCell(cell: CategoriesCellView, atIndexPath indexPath: NSIndexPath) {
        let object: SubCategory = self.fetchedResultsController.objectAtIndexPath(indexPath) as! SubCategory
        cell.name.text = "\(object.name)"
    }
    
    //MARK: - Fetch Control
    
    var fetchedResultsController: NSFetchedResultsController {
        print("fetchedResultsController")
        if self._fetchedResultsController != nil {
            print("ALREADY EXISTS")
            return self._fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("SubCategory", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        print("NSPREDICATE :: \(self.category!.name)")
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
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Left)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)! as! CategoriesCellView, atIndexPath: indexPath!)
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }   
}