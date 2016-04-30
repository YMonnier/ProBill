//
//  AddBillViewController.swift
//  ProBill
//
//  Created by Ysée Monnier on 30/04/16.
//  Copyright © 2016 MONNIER Ysee. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AddBillViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //ImagePciker
    var imagePicker: UIImagePickerController!
    @IBOutlet weak var takePictureButton: UIButton!

    //TextField
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var subCategoryTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    var activeTextField:UITextField?
    
    //PickerView
    let categoryPickerView: UIPickerView = UIPickerView()
    let subCategoryPickerView: UIPickerView = UIPickerView()
    let datePickerView:UIDatePicker = UIDatePicker()
    
    //Save info
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var picture: UIImageView!
    var subCategorieSelected: SubCategory?
    var dateSelected: NSDate?
    
    //Data
    var data: [Category] = []
    var subCatData: [SubCategory] = []
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        self.title = "Your bill"
        
        //Right button (save bill)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Add", style: .Plain, target: self, action: #selector(AddBillViewController.saveBill))
        self.navigationItem.rightBarButtonItem = doneButton
        
        //TextField
        self.categoryTextField.delegate = self
        self.subCategoryTextField.delegate = self
        self.dateTextField.delegate = self
        
        //UIPickerView
        self.initCategoryPicker()
        self.initSubCategoryPicker()
        self.initDatePicker()
        
        //PictureButton
        self.initPictureButton()
        
        self.loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - TextField
    /**
     selection active tectField
     */
    func textFieldDidBeginEditing(textField: UITextField) { // became first responder
        print("activeTextField")
        self.activeTextField = textField
        switch textField {
        case self.categoryTextField:
            if !self.data.isEmpty {
                self.categoryPickerView.selectedRowInComponent(0)
                self.pickerView(self.categoryPickerView, didSelectRow: 0, inComponent: 0)
            }
            break
        case self.subCategoryTextField:
            if !self.subCatData.isEmpty {
                self.subCategoryPickerView.selectedRowInComponent(0)
                self.pickerView(self.subCategoryPickerView, didSelectRow: 0, inComponent: 0)
            }
            break
        default:
            return
        }
    }
    
    /**
     dismiss inputView when user touch outside the view
     */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    //MARK: - ToolBar (inputView)
    
    /**
     Create toolbar with done button which dismiss the view
     - returns: toolbar
     */
    private func createToolBar() -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 44))
        var items = [UIBarButtonItem]()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(AddBillViewController.donePressed))
        
        items.append(spaceButton)
        items.append(spaceButton)
        items.append(doneButton)
        toolbar.barStyle = UIBarStyle.Black
        toolbar.barTintColor = PBColor.yellow
        toolbar.setItems(items, animated: true)
        toolbar.userInteractionEnabled = true
        return toolbar
    }
    
    //MARK: - UIDatePicker
    /**
     Initilize DatePicker
     */
    private func initDatePicker() {
        self.createToolBar()
        self.datePickerView.backgroundColor = UIColor.whiteColor()
        self.datePickerView.datePickerMode = .Date
        
        //Add action when datePicker change value
        datePickerView.addTarget(self, action: #selector(AddBillViewController.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
        
        let toolBar: UIToolbar = self.createToolBar()
        toolBar
        self.datePickerView.frame = CGRectMake(0, 0, 500, 250)
        self.dateTextField.inputAccessoryView = toolBar
        self.dateTextField.inputView = self.datePickerView
    }
    
    /**
     handler when date picker change value
     - parameter sender: sender UIDatePicker
     */
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        dateTextField.text = dateFormatter.stringFromDate(sender.date)
        self.dateSelected = sender.date
    }
    
    //MARK: - UIPickerView
    /**
     Initilize CategoryPicker
     */
    private func initCategoryPicker() {
        self.categoryPickerView.backgroundColor = UIColor.whiteColor()
        let toolbar: UIToolbar = self.createToolBar()
        self.categoryPickerView.delegate = self
        self.categoryPickerView.dataSource = self
        self.categoryPickerView.frame = CGRectMake(0, 0, 500, 250)
        self.categoryTextField.inputAccessoryView = toolbar
        self.categoryTextField.inputView = self.categoryPickerView
    }
    
    /**
     Initilize SubCategoryPicker
     */
    private func initSubCategoryPicker() {
        self.subCategoryPickerView.backgroundColor = UIColor.whiteColor()
        let toolbar: UIToolbar = self.createToolBar()
        self.subCategoryPickerView.delegate = self
        self.subCategoryPickerView.dataSource = self
        self.subCategoryPickerView.frame = CGRectMake(0, 0, 500, 250)
        self.subCategoryTextField.inputAccessoryView = toolbar
        self.subCategoryTextField.inputView = self.subCategoryPickerView
    }
    
    /**
     dismiss inputView
     */
    func donePressed() {
        self.activeTextField?.resignFirstResponder()
    }
    
    //MARK: - PickerView Delegate
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case self.categoryPickerView:
            return self.data.count
        case self.subCategoryPickerView:
            return self.subCatData.count
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case self.categoryPickerView:
            return self.data[row].name
        case self.subCategoryPickerView:
            return self.subCatData[row].name
        default:
            return ""
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        autoreleasepool {
            switch pickerView {
            case self.categoryPickerView:
                print("categoryPickerView:: \(row)")
                self.categoryTextField.text = self.data[row].name
                self.subCatData = Array(self.data[row].subCategories)
                print("categoryPickerView:: END")
                break
            case self.subCategoryPickerView:
                self.subCategoryTextField.text = self.subCatData[row].name
                self.subCategorieSelected = self.subCatData[row]
                break
            default:
                return
            }
            
        }
    }
    
    //MARK: - Picture
    /**
        Initilize picture button (Design)
    */
    private func initPictureButton() {
        self.takePictureButton.layer.cornerRadius = 0.5 * self.takePictureButton.bounds.size.width
        self.takePictureButton.layer.borderWidth = 3.0
        self.takePictureButton.layer.borderColor = PBColor.gray.CGColor
    }
    
    @IBAction func takePictureAction(sender: UIButton) {
        print("takePicture")
        self.imagePicker =  UIImagePickerController()
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .Camera
        
        self.presentViewController(self.imagePicker, animated: true, completion: nil)
    }
    
    //Delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        self.picture.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        //UIImagePNGRepresentation(<#T##image: UIImage##UIImage#>)
    }
    
    
    //MARK: - Save Action
    func saveBill() {
        print(#function)
        if self.subCategorieSelected != nil && self.dateSelected != nil && self.picture.image != nil && !self.priceTextField.text!.isEmpty {
            let bill: Bill = NSEntityDescription.insertNewObjectForEntityForName("Bill", inManagedObjectContext: self.managedObjectContext!) as! Bill
            bill.date = self.dateSelected!
            bill.picture = UIImagePNGRepresentation(self.picture.image!)!
            print("OKOK")
            bill.price = Double(self.priceTextField.text!.stringByReplacingOccurrencesOfString(",", withString: "."))!
            print("OKOK")
            do {
                try self.managedObjectContext?.save()
                print("Save OK...")
                self.navigationController?.popViewControllerAnimated(true)
            } catch let error as NSError {
                print("Error \(object_getClass(self)) \(#function) : \(error.debugDescription))")
                self.showSimpleAlert("Add Bill", message: "Error in \(object_getClass(self)) \(#function): \(error.debugDescription))")
            }
        } else {
            print("Error save")
            self.showSimpleAlert("Add Bill", message: "Error: please check if you have put all information.")
        }
    }
    
    //MARK: - LoadData
    /**
     fetch all categories and save it to use with PickerUse
     */
    private func loadData() {
        autoreleasepool {
            var error: NSError? = nil
            var result: [AnyObject]?
            
            let fetch: NSFetchRequest = NSFetchRequest(entityName: "Category")
            
            do {
                result = try self.managedObjectContext!.executeFetchRequest(fetch)
            } catch let nserror1 as NSError{
                error = nserror1
                result = nil
            }
            
            if result != nil {
                self.data = result as! [Category]
            }
        }
    }
}