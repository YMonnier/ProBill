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

class StatisticsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChartViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pieCharView: PieChartView!
    
    let colors = [
        ChartColorTemplates.vordiplom(),
        ChartColorTemplates.joyful(),
        ChartColorTemplates.colorful(),
        ChartColorTemplates.liberty(),
        ChartColorTemplates.pastel(),
        UIColor(red: 51/255, green: 181/255, blue: 229, alpha: 1.0)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .None
        //Chart properties
        
        self.pieCharView.usePercentValuesEnabled = true
        self.pieCharView.drawSlicesUnderHoleEnabled = false
        self.pieCharView.holeRadiusPercent = 0.58
        self.pieCharView.transparentCircleRadiusPercent = 0.61
        self.pieCharView.descriptionText = ""
        self.pieCharView.setExtraOffsets(left: 0, top: 50, right: 0, bottom: 50)
        self.pieCharView.drawHoleEnabled = true
        self.pieCharView.rotationAngle = 0.0
        self.pieCharView.rotationEnabled = true
        self.pieCharView.highlightPerTapEnabled = true
        self.pieCharView.legend.enabled = true;
        self.pieCharView.legend.position = .RightOfChart
        self.pieCharView.legend.xEntrySpace = 7.0
        self.pieCharView.legend.yEntrySpace = 0.0
        self.pieCharView.legend.yOffset = 0.0
        self.pieCharView.delegate = self;
        
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0]
        
        
        self.loadPieChart(months, values: unitsSold)
        
        //self.pieCharView.animate(xAxisDuration: 1.5, easingOption: .EaseOutBack)
        
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
    
    //MARK: - PieChar Delegate
    func chartValueNothingSelected(chartView: ChartViewBase) {
        
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        
    }
    
    
    
    //MARK: - Load data
    private func loadData() {
        
    }
    
    private func loadPieChart(dataPoints: [String], values: [Double]) {
        print(#function)
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Units Sold")
        
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        self.pieCharView.data = pieChartData
        
        var colors: [UIColor] = []
        
        //Random color depending number of elements
        for _ in 0..<dataPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        
        pieChartDataSet.colors = colors
        
        print(#function)
    }
}