//
//  TPTSwipingTableViewCellDelegate.swift
//  TPTSwipingTableViewCell
//
//  Created by Jim Rutherford on 2015-07-30.
//  Copyright © 2015 Braxio Interactive. All rights reserved.
//

import Foundation
import UIKit

protocol TPTSwipingTableViewCellDelegate {
    
    func swipeTableViewCellDidStartSwiping(cell:TPTSwipingTableViewCell)
    
    func swipeTableViewCellDidEndSwiping(cell:TPTSwipingTableViewCell)
    
    func swipeTableViewCell(cell:TPTSwipingTableViewCell, didSwipeWithPercentage percentage:CGFloat)

}

