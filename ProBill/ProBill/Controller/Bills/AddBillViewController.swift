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

class AddBillViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //ImagePciker
    var imagePicker: UIImagePickerController!
    @IBOutlet weak var takePictureButton: UIButton!
    @IBOutlet weak var commentTextview: UITextView!
    
    @IBOutlet weak var pictureCollectionView: UICollectionView!
    
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
    
    var pictures: [UIImage] = []
    var subCategorieSelected: SubCategory?
    var dateSelected: Date?
    
    //Data
    var data: [Category] = []
    var subCatData: [SubCategory] = []
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        self.title = "Your bill"
        
        //Register
        self.pictureCollectionView!.register(UINib(nibName: "PhotoCellView", bundle: Bundle(for: AddBillViewController.self )), forCellWithReuseIdentifier: "PhotoCell")
        self.pictureCollectionView!.register(UINib(nibName: "AddPhotoCellView", bundle: Bundle(for: AddBillViewController.self )), forCellWithReuseIdentifier: "AddPhotoCell")

        
        //Right button (save bill)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(AddBillViewController.saveBill))
        self.navigationItem.rightBarButtonItem = doneButton
        
        //PictureCollectionView
        self.pictureCollectionView.delegate = self
        self.pictureCollectionView.dataSource = self
        self.pictureCollectionView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        self.pictureCollectionView.layer.zPosition = 100
        
        //TextField
        self.categoryTextField.delegate = self
        self.subCategoryTextField.delegate = self
        self.dateTextField.delegate = self
        
        //TextView (comment)
        self.commentTextview.delegate = self
        self.commentTextview.layer.borderColor = UIColor.lightGray.cgColor
        self.commentTextview.textColor = UIColor.lightGray
        self.commentTextview.layer.borderWidth = 0.5
        self.commentTextview.layer.cornerRadius = 5
        
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
    
    //MARK:- TextView (comment)

    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = UIColor.black
    }
    
    
    //MARK: - TextField
    /**
     selection active tectField
     */
    func textFieldDidBeginEditing(_ textField: UITextField) { // became first responder
        print("activeTextField")
        self.activeTextField = textField
        switch textField {
        case self.categoryTextField:
            if !self.data.isEmpty {
                self.categoryPickerView.selectedRow(inComponent: 0)
                self.pickerView(self.categoryPickerView, didSelectRow: 0, inComponent: 0)
            } else {
                self.showSimpleAlert("Your bill", message: "There are no categories.")
            }
            break
        case self.subCategoryTextField:
            if !self.subCatData.isEmpty {
                self.subCategoryPickerView.selectedRow(inComponent: 0)
                self.pickerView(self.subCategoryPickerView, didSelectRow: 0, inComponent: 0)
            } else {
                self.showSimpleAlert("Your bill", message: "There are no sub categories.")
            }
            break
        default:
            return
        }
    }
    
    /**
     dismiss inputView when user touch outside the view
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    //MARK: - ToolBar (inputView)
    
    /**
     Create toolbar with done button which dismiss the view
     - returns: toolbar
     */
    fileprivate func createToolBar() -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        var items = [UIBarButtonItem]()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(AddBillViewController.donePressed))
        
        items.append(spaceButton)
        items.append(spaceButton)
        items.append(doneButton)
        toolbar.barStyle = UIBarStyle.black
        toolbar.barTintColor = PBColor.yellow
        toolbar.setItems(items, animated: true)
        toolbar.isUserInteractionEnabled = true
        return toolbar
    }
    
    //MARK: - UIDatePicker
    /**
     Initilize DatePicker
     */
    fileprivate func initDatePicker() {
        self.createToolBar()
        self.datePickerView.backgroundColor = UIColor.white
        self.datePickerView.datePickerMode = .date
        
        //Add action when datePicker change value
        datePickerView.addTarget(self, action: #selector(AddBillViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
        
        let toolBar: UIToolbar = self.createToolBar()
        toolBar
        self.datePickerView.frame = CGRect(x: 0, y: 0, width: 500, height: 250)
        self.dateTextField.inputAccessoryView = toolBar
        self.dateTextField.inputView = self.datePickerView
    }
    
    /**
     handler when date picker change value
     - parameter sender: sender UIDatePicker
     */
    func datePickerValueChanged(_ sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateTextField.text = dateFormatter.string(from: sender.date)
        self.dateSelected = sender.date
    }
    
    //MARK: - UIPickerView
    /**
     Initilize CategoryPicker
     */
    fileprivate func initCategoryPicker() {
        self.categoryPickerView.backgroundColor = UIColor.white
        let toolbar: UIToolbar = self.createToolBar()
        self.categoryPickerView.delegate = self
        self.categoryPickerView.dataSource = self
        self.categoryPickerView.frame = CGRect(x: 0, y: 0, width: 500, height: 250)
        self.categoryTextField.inputAccessoryView = toolbar
        self.categoryTextField.inputView = self.categoryPickerView
    }
    
    /**
     Initilize SubCategoryPicker
     */
    fileprivate func initSubCategoryPicker() {
        self.subCategoryPickerView.backgroundColor = UIColor.white
        let toolbar: UIToolbar = self.createToolBar()
        self.subCategoryPickerView.delegate = self
        self.subCategoryPickerView.dataSource = self
        self.subCategoryPickerView.frame = CGRect(x: 0, y: 0, width: 500, height: 250)
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case self.categoryPickerView:
            return self.data.count
        case self.subCategoryPickerView:
            return self.subCatData.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case self.categoryPickerView:
            return self.data[row].name
        case self.subCategoryPickerView:
            return self.subCatData[row].name
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        autoreleasepool {
            switch pickerView {
            case self.categoryPickerView:
                if !self.data.isEmpty {
                    self.categoryTextField.text = self.data[row].name
                    self.subCatData = Array(self.data[row].subCategories)
                }
                break
            case self.subCategoryPickerView:
                if !self.subCatData.isEmpty {
                    self.subCategoryTextField.text = self.subCatData[row].name
                    self.subCategorieSelected = self.subCatData[row]
                }
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
    fileprivate func initPictureButton() {
        self.takePictureButton.layer.cornerRadius = 0.5 * self.takePictureButton.bounds.size.width
        self.takePictureButton.layer.borderWidth = 3.0
        self.takePictureButton.layer.borderColor = PBColor.blue.cgColor
        self.takePictureButton.layer.zPosition = 100
    }
    
    @IBAction func takePictureAction(_ sender: UIButton) {
        print("takePicture")
        self.imagePicker =  UIImagePickerController()
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .camera
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    //Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        let imageFromCamera = (info[UIImagePickerControllerOriginalImage] as? UIImage)
        imageFromCamera!.fixOrientation()
        self.picture.image = imageFromCamera
        self.pictures.append(self.picture.image!)
        self.pictureCollectionView.reloadData()
    }
    
    //MARK: PictureCollectionView delegate/datasource
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pictures.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("AddPicturecell... \(indexPath)")
        //var cell: UICollectionViewCell?
        
        if (indexPath as NSIndexPath).row == self.pictures.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddPhotoCell", for: indexPath)
            cell.backgroundColor = UIColor.clear
            return cell
        } else {
            let cell: PhotoCellView = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCellView
            cell.picture.image = self.pictures[(indexPath as NSIndexPath).row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("DidSelectItem ... \(indexPath)")
        //let cell = collectionView.cellForItemAtIndexPath(indexPath) as! FTCalendarCellView
        if (indexPath as NSIndexPath).row == self.pictures.count {
            self.takePictureAction(self.takePictureButton)
        } else {
            self.picture.image = self.pictures[(indexPath as NSIndexPath).row]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 30,height: 40);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(5, 20, 0, 0);
    }

    //MARK: - Save Action
    
    func saveBill() {
        print(#function)
        if self.subCategorieSelected != nil && self.dateSelected != nil && self.picture.image != nil && !self.priceTextField.text!.isEmpty {
 
            let bill: Bill = NSEntityDescription.insertNewObject(forEntityName: "Bill", into: self.managedObjectContext!) as! Bill
            
            bill.date = self.dateSelected!
            bill.price = Double(self.priceTextField.text!.replacingOccurrences(of: ",", with: "."))!
            bill.subCategory = self.subCategorieSelected!
            bill.comment = self.commentTextview.text
            
            //Cross all images
            for image in self.pictures {
                let picture: Picture = NSEntityDescription.insertNewObject(forEntityName: "Picture", into: self.managedObjectContext!) as! Picture
                
                //Save JPEG image with 0.0 compression (lowest quality)
                picture.image = UIImageJPEGRepresentation(image, 0.0)!
                bill.pictures.insert(picture)
            }

            do {
                try self.managedObjectContext?.save()
                self.navigationController?.popViewController(animated: true)
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
    fileprivate func loadData() {
        autoreleasepool {
            var error: NSError? = nil
            var result: [AnyObject]?
            
            let fetch: NSFetchRequest<Category> = NSFetchRequest(entityName: "Category")
            
            do {
                result = try self.managedObjectContext!.fetch(fetch)
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
