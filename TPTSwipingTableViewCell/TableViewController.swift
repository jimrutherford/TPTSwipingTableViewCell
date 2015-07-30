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


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("swipeCell", forIndexPath: indexPath)

        cell.textLabel!.text = tableData[indexPath.row]

        return cell
    }


}
