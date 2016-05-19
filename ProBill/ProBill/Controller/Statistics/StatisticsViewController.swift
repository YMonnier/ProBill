//
//  StatisticsViewController.swift
//  ProBill
//
//  Created by Ysée Monnier on 19/05/16.
//  Copyright © 2016 MONNIER Ysee. All rights reserved.
//

import Foundation
import UIKit

class StatisticsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: TableView Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    //MARK: - Load data
    private func loadData() {
        
    }
}