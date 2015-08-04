//
//  TableViewController.swift
//  TPTSwipingTableViewCell
//
//  Created by Jim Rutherford on 2015-07-30.
//  Copyright © 2015 Braxio Interactive. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    
    let tableData = ["The Barr Brothers", "Avvett Brothers"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.reloadData()
    }


    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableData.count
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:TPTSwipingTableViewCell = tableView.dequeueReusableCellWithIdentifier("swipeCell", forIndexPath: indexPath) as! TPTSwipingTableViewCell

        cell.myLabel!.text = tableData[indexPath.row]

        configureCell(cell, forRowAtIndexPath:indexPath)
        
        return cell
    }
    
    func configureCell(cell:TPTSwipingTableViewCell, forRowAtIndexPath:NSIndexPath)
    {
        cell.defaultColor = UIColor.lightGrayColor()
        
        let greenColor = UIColor(colorLiteralRed:0.33, green:0.84, blue:0.31, alpha:1.0)
        let redColor = UIColor(colorLiteralRed:0.91, green:0.24, blue:0.05, alpha:1.0)
        let yellowColor = UIColor(colorLiteralRed:1.0, green:0.85, blue:0.22, alpha:1.0)
        let brownColor = UIColor(colorLiteralRed:0.81, green:0.58, blue:0.38, alpha:1.0)
        
        let actionLeft1 = TPTSwipeCellAction(iconName: "comment", color: greenColor, trigger:0.25, side:.Left, mode: .Switch, completionBlock: { (cell, mode) -> Void in
            print("Leave a comment")
        })
        
        let actionLeft2 = TPTSwipeCellAction(iconName: "config", color: redColor, trigger:0.6, side:.Left, mode: .Switch, completionBlock: { (cell, mode) -> Void in
            print("Do some settings")
        })
        
        
        let actionRight1 = TPTSwipeCellAction(iconName: "heart", color: yellowColor, trigger:0.25, side:.Right, mode: .Switch, completionBlock: { (cell, mode) -> Void in
            print("I like it!")
        })
        
        let actionRight2 = TPTSwipeCellAction(iconName: "tag", color: brownColor, trigger:0.6, side:.Right, mode: .Switch, completionBlock: { (cell, mode) -> Void in
            print("Tag! You're it!")
        })
        
        cell.actionItems = [actionLeft1, actionLeft2, actionRight1, actionRight2]
        
    }
    
}
