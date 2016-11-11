//
//  StatisticsViewController.swift
//  ProBill
//
//  Created by Ysée Monnier on 19/05/16.
//  Copyright © 2016 MONNIER Ysee. All rights reserved.
//

import Foundation
import UIKit
import Charts
import CoreData

class StatisticsViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var pieCharView: PieChartView!
    @IBOutlet weak var barCharView: BarChartView!
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var data: [Category] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge()
        
        self.managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        
        //Chart properties
        self.pieCharView.usePercentValuesEnabled = true
        self.pieCharView.drawSlicesUnderHoleEnabled = false
        self.pieCharView.holeRadiusPercent = 0.58
        self.pieCharView.transparentCircleRadiusPercent = 0.61
        self.pieCharView.chartDescription?.text = ""
        self.pieCharView.setExtraOffsets(left: 0, top: 50, right: 0, bottom: 50)
        self.pieCharView.drawHoleEnabled = true
        self.pieCharView.rotationAngle = 0.0
        self.pieCharView.rotationEnabled = true
        self.pieCharView.highlightPerTapEnabled = true
        self.pieCharView.legend.enabled = true
        self.pieCharView.legend.horizontalAlignment = .right
        self.pieCharView.legend.xEntrySpace = 7.0
        self.pieCharView.legend.yEntrySpace = 0.0
        self.pieCharView.legend.yOffset = 0.0
        self.pieCharView.delegate = self
        
        self.barCharView.chartDescription?.text = "";
        self.barCharView.noDataText = "You need to select a pie chart element."
        
        self.barCharView.drawGridBackgroundEnabled = false
        
        self.barCharView.dragEnabled = true
        self.barCharView.setScaleEnabled(true)
        self.barCharView.pinchZoomEnabled = true
        
        let xAxis: XAxis = self.barCharView.xAxis
        xAxis.labelPosition = .bottom//XAxisLabelPositionBottom;
        
        self.barCharView.rightAxis.enabled = false
        
        self.loadData()
        self.loadPieChart()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadData()
        self.loadPieChart()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - PieChar Delegate
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        if chartView == self.pieCharView {
            
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: Highlight) {
        if chartView == self.pieCharView {
            let x = Int(entry.x)
            self.loadBarChar(x)
            print(entry.description)
            print(self.data[x].name)
        }
    }
    
    //MARK: - Load data
    
    fileprivate func loadData() {
        autoreleasepool {
            var error: NSError? = nil
            var result: [AnyObject]?
            
            let fetch = NSFetchRequest<Category>(entityName: "Category")
            do {
                result = try self.managedObjectContext!.fetch(fetch)
            } catch let nserror1 as NSError{
                error = nserror1
                result = nil
            }
            if result != nil {
                self.data = []
                self.data = (result as! [Category]).filter({ (sc) -> Bool in
                    !sc.subCategories.isEmpty
                })
            }
        }
    }
    /**
     Load the Pie chart with data from CoreData(Category)
     */
    fileprivate func loadPieChart() {
        print(#function)
        var subcategories: [String] = [] //X
        var dataEntries: [ChartDataEntry] = [] //Y
        
        for i in 0..<self.data.count {
            var sum: Double = 0.0
            let subC = Array(self.data[i].subCategories)
            for sub in subC { for bill in Array(sub.bills) {sum += bill.price} }
            let dataEntry = ChartDataEntry(x: sum, y: Double(i))
            dataEntries.append(dataEntry)
        }
        
        //Get all categories name
        for i in 0..<self.data.count {
            subcategories.append(self.data[i].name)
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "Categories")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        //let pieChartData = PieChartData(xVals: subcategories, dataSet: pieChartDataSet)
        self.pieCharView.data = pieChartData
        
        
        //Random color depending number of elements
        var colors: [UIColor] = []
        for _ in 0..<subcategories.count {
            colors.append(UIColor.random())
        }
        
        pieChartDataSet.colors = colors
        let nFormmater: NumberFormatter = NumberFormatter()
        nFormmater.numberStyle = .percent
        nFormmater.maximumFractionDigits = 1
        nFormmater.multiplier = 1.0
        nFormmater.percentSymbol = " %"
        
        //pieChartData.setValueFormatter(nFormmater)
        pieChartData.setValueFont(NSUIFont(name: "Avenir-Light", size: 11))
        //pieChartData.setValueTextColor(UIColor.blackColor())
        
        print(#function)
    }
    
    fileprivate func loadBarChar(_ index: Int) {
        let subCategories: [SubCategory] = Array(self.data[index].subCategories)
        var xValues: [String?] = [] //X
        var dataEntries: [BarChartDataEntry] = [] //Y
        
        for i in 0..<subCategories.count {
            xValues.append(subCategories[i].name)
        }
        
        for i in 0..<subCategories.count {
            var sum: Double = 0.0
            for bill in Array(subCategories[i].bills) { sum += bill.price }
            //let dataEntry = BarChartDataEntry(value: sum, xIndex: i)
            let dataEntry = BarChartDataEntry(x: sum, y: Double(i))
            dataEntries.append(dataEntry)
        }
        
        let barSet = BarChartDataSet(values: dataEntries, label: "Sub-Categories")
        barSet.setColor(UIColor.random())
        
        let barData = BarChartData(dataSet: barSet)//BarChartData(xVals: xValues, dataSet: barSet)
        //barData.groupSpace = 0.8
        barData.setValueFont(NSUIFont(name: "Avenir-Light", size: 14))
        self.barCharView.data = barData
    }
}
