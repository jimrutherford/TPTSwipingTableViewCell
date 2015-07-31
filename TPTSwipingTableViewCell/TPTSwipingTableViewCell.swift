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

/**
*  `MCSwipeCompletionBlock`
*
*  @param cell  Currently swiped `MCSwipeTableViewCell`.
*  @param state `MCSwipeTableViewCellState` which has been triggered.
*  @param mode  `MCSwipeTableViewCellMode` used for for swiping.
*
*  @return No return value.
*/

typealias TPTSwipeCompletionBlock = (TPTSwipingTableViewCell, TPTSwipeTableViewCellState, TPTSwipeTableViewCellMode) -> Void


class TPTSwipingTableViewCell: UITableViewCell {
    
    // MARK: - Public/Internal Properties
    var defaultColor:UIColor?
    
    var color1:UIColor = UIColor()
    var color2:UIColor = UIColor()
    var color3:UIColor = UIColor()
    var color4:UIColor = UIColor()
    
    var view1:UIView = UIView()
    var view2:UIView = UIView()
    var view3:UIView = UIView()
    var view4:UIView = UIView()
    
    var animationDuration:NSTimeInterval = 0.4
    var damping = 0.6
    var velocity = 0.9
    
    var firstTrigger = 0.25
    var secondTrigger = 0.75
    
    var isDragging = false
    var shouldDrag = true
    var shouldAnimateIcons = true
    
    var modeForState1: TPTSwipeTableViewCellMode = .None
    var modeForState2: TPTSwipeTableViewCellMode = .None
    var modeForState3: TPTSwipeTableViewCellMode = .None
    var modeForState4: TPTSwipeTableViewCellMode = .None
    
    // MARK: - Private properties
    var direction:TPTSwipeTableViewCellDirection = .Center
    var currentPercentage:CGFloat = 0.0
    var isExited = false
    
    var panGestureRecognizer = UIPanGestureRecognizer()
    var contentScreenshotView:UIImageView?
    var colorIndicatorView = UIView()
    var slidingView  = UIView()
    var activeView = UIView()
    
    // MARK: - Initialziers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
    }
    

    func setup()
    {
        setupDefaults()
        
        // Setup Gesture Recognizer.
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGestureRecognizer:")
        self.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
    }
    
    func setupDefaults()
    {
        isExited = false
        isDragging = false
        shouldDrag = true
        shouldAnimateIcons = true
        
        firstTrigger = 0.25
        secondTrigger = 0.75
        damping = 0.6
        velocity = 0.9
        animationDuration = 0.4
        
        defaultColor = UIColor.whiteColor()
        
        modeForState1 = .None
        modeForState2 = .None
        modeForState3 = .None
        modeForState4 = .None
        
    }



    // MARK: - Public Methods
    func setSwipeGestureWithView(view:UIView,
        color:UIColor,
        mode:TPTSwipeTableViewCellMode,
        state:TPTSwipeTableViewCellState,
        completionBlock:TPTSwipeCompletionBlock)
    {
        
    }
    
    //- (void)swipeToOriginWithCompletion:(void(^)(void))completion;
    
    
    // MARK: - Private Methods
    
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // uninstallSwipingView()
        // initDefaults()
    }
    
    // MARK: - View Manipulation
    
    func setupSwipingView()
    {
        if let _ = contentScreenshotView
        {
            return;
        }
    
        // If the content view background is transparent we get the background color.
        let isContentViewBackgroundClear = !(self.contentView.backgroundColor != nil);
    
        if (isContentViewBackgroundClear) {
            let isBackgroundClear = self.backgroundColor?.isEqual(UIColor.clearColor());

            self.contentView.backgroundColor = (isBackgroundClear != nil) ? UIColor.whiteColor() : self.backgroundColor;
        }
    
        let contentViewScreenshotImage = imageWithView(self);
        
        if (isContentViewBackgroundClear) {
            self.contentView.backgroundColor = nil;
        }
    
        colorIndicatorView = UIView(frame: self.bounds)
        colorIndicatorView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        
        if let color = defaultColor
        {
            colorIndicatorView.backgroundColor = color
        } else {
            colorIndicatorView.backgroundColor = UIColor.clearColor()
        }
        
        addSubview(colorIndicatorView)
    
        slidingView = UIView();
        slidingView.contentMode = .Center
        colorIndicatorView.addSubview(slidingView)
    
        contentScreenshotView = UIImageView(image: contentViewScreenshotImage)
        addSubview(contentScreenshotView!)
    }
    
    
    // MARK: - Utilities
    
    func imageWithView(view:UIView) -> UIImage
    {
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scale);
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    
}
