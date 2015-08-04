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

        //tableView.delegate = self;
        //tableView.dataSource = self;
        
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
        
        let commentView = viewWithImageName("comment")
        let configView = viewWithImageName("config")
        let heartView = viewWithImageName("heart")
        let tagView = viewWithImageName("tag")
        
        let greenColor = UIColor(colorLiteralRed:0.33, green:0.84, blue:0.31, alpha:1.0)
        let redColor = UIColor(colorLiteralRed:0.91, green:0.24, blue:0.05, alpha:1.0)
        let yellowColor = UIColor(colorLiteralRed:1.0, green:0.85, blue:0.22, alpha:1.0)
        let brownColor = UIColor(colorLiteralRed:0.81, green:0.58, blue:0.38, alpha:1.0)
        
        cell.setSwipeGestureWithView(commentView, color: greenColor, mode: .Switch, state: .State1, completionBlock: { (cell, state, mode) -> Void in
            
            
            
        })
        
        cell.setSwipeGestureWithView(configView, color: redColor, mode: .Switch, state: .State2, completionBlock: { (cell, state, mode) -> Void in
            
            
            
        })
        
        cell.setSwipeGestureWithView(heartView, color: yellowColor, mode: .Switch, state: .State3, completionBlock: { (cell, state, mode) -> Void in
            
            
            
        })
        
        cell.setSwipeGestureWithView(tagView, color: brownColor, mode: .Switch, state: .State4, completionBlock: { (cell, state, mode) -> Void in
            
            
            
        })
        
    }
    
    
    func viewWithImageName(imageName:String) -> UIView {
        let image = UIImage(named:imageName)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .Center
        return imageView
    }
    
}
