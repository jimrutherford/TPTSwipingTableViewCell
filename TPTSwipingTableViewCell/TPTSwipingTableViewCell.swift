//
//  TPTSwipingTableViewCell.swift
//  TPTSwipingTableViewCell
//
//  Created by Jim Rutherford on 2015-07-30.
//  Copyright © 2015 Braxio Interactive. All rights reserved.
//

import UIKit

enum TPTSwipeTableViewCellState:Int {
    case stateNone = 0
    case state1 = 1
    case state2 = 2
    case state3 = 3
    case state4 = 4
}

enum TPTSwipeTableViewCellMode:Int {
    case None = 0
    case Exit = 1
    case Switch = 2
}

enum TPTSwipeTableViewCellDirection:Int {
    case Left = 0
    case Center = 1
    case Right = 2
}


class TPTSwipingTableViewCell: UITableViewCell {

    // MARK: - Public/Internal Properties
    var defaultColor:UIColor
    
    var color1:UIColor
    var color2:UIColor
    var color3:UIColor
    var color4:UIColor
    
    var view1:UIView
    var view2:UIView
    var view3:UIView
    var view4:UIView
    
    var animationDuration:NSTimeInterval = 0.4
    var damping:CGFloat = 0.6
    var velocity:CGFloat = 0.9
    
    var firstTrigger:CGFloat = 0.25
    var secondTrigger:CGFloat = 0.75
    
    var isDragging:Bool = false
    var shouldDrag:Bool = true
    var shouldAnimateIcons = true
    
    var modeForState1: TPTSwipeTableViewCellMode = .None
    var modeForState2: TPTSwipeTableViewCellMode = .None
    var modeForState3: TPTSwipeTableViewCellMode = .None
    var modeForState4: TPTSwipeTableViewCellMode = .None
    
    // MARK: - Private properties
    var direction:TPTSwipeTableViewCellDirection
    var currentPercentage:CGFloat
    var isExited = false
    
    var panGestureRecognizer:UIPanGestureRecognizer
    var contentScreenshotView:UIImageView
    var colorIndicatorView:UIView
    var slidingView:UIView
    var activeView:UIView
    
    // MARK: - Initialziers
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK: - Overridden Methods
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Public Methods
    func setSwipeGestureWithView(view:UIView,
        color:UIColor,
        mode:MCSwipeTableViewCellMode,
        state:MCSwipeTableViewCellState,
        completionBlock:MCSwipeCompletionBlock)
    {
        
    }
    
    //- (void)swipeToOriginWithCompletion:(void(^)(void))completion;
    
    
    // MARK: - Private Methods
    
}
