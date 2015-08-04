//
//  TPTSwipingTableViewCell.swift
//  TPTSwipingTableViewCell
//
//  Created by Jim Rutherford on 2015-07-30.
//  Copyright © 2015 Braxio Interactive. All rights reserved.
//

import UIKit

enum TPTSwipeTableViewCellState:Int {
    case StateNone = 0
    case State1 = 1
    case State2 = 2
    case State3 = 3
    case State4 = 4
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
*  `TPTSwipeCompletionBlock`
*
*  @param cell  Currently swiped `MCSwipeTableViewCell`.
*  @param state `TPTSwipeTableViewCellState` which has been triggered.
*  @param mode  `TPTSwipeTableViewCellMode` used for for swiping.
*
*  @return No return value.
*/

typealias TPTSwipeCompletionBlock = (TPTSwipingTableViewCell, TPTSwipeTableViewCellState, TPTSwipeTableViewCellMode) -> Void


class TPTSwipingTableViewCell: UITableViewCell {
    
    // MARK: - Constants
    let kMCBounceDuration1:NSTimeInterval      = 0.2  // Duration of the first part of the bounce animation
    let kMCBounceDuration2:NSTimeInterval      = 0.1  // Duration of the second part of the bounce animation
    let kMCDurationLowLimit:NSTimeInterval     = 0.25 // Lowest duration when swiping the cell because we try to simulate velocity
    let kMCDurationHighLimit:NSTimeInterval    = 0.1  // Highest duration when swiping the cell because we try to simulate velocity
    let kMCBounceAmplitude:CGFloat = 20.0 // Maximum bounce amplitude when using the MCSwipeTableViewCellModeSwitch mode
    
    // MARK: - Public/Internal Properties
    
    var delegate: TPTSwipingTableViewCellDelegate?
    
    var defaultColor:UIColor?
    
    var completionBlock1:TPTSwipeCompletionBlock?
    var completionBlock2:TPTSwipeCompletionBlock?
    var completionBlock3:TPTSwipeCompletionBlock?
    var completionBlock4:TPTSwipeCompletionBlock?
    
    var color1:UIColor = UIColor()
    var color2:UIColor = UIColor()
    var color3:UIColor = UIColor()
    var color4:UIColor = UIColor()
    
    var view1:UIView = UIView()
    var view2:UIView = UIView()
    var view3:UIView = UIView()
    var view4:UIView = UIView()
    
    var modeForState1: TPTSwipeTableViewCellMode = .None
    var modeForState2: TPTSwipeTableViewCellMode = .None
    var modeForState3: TPTSwipeTableViewCellMode = .None
    var modeForState4: TPTSwipeTableViewCellMode = .None
    
    var animationDuration:NSTimeInterval = 0.4
    var damping = 0.6
    var velocity = 0.9
    
    var firstTrigger:CGFloat = 0.25
    var secondTrigger:CGFloat = 0.75
    
    var isDragging = false
    var shouldDrag = true
    var shouldAnimateIcons = true
    
    @IBOutlet weak var myLabel: UILabel!
    
    // MARK: - Private properties
    var direction:TPTSwipeTableViewCellDirection = .Center
    var currentPercentage:CGFloat = 0.0
    var isExited = false
    
    var panGestureRecognizer = UIPanGestureRecognizer()
    var contentScreenshotView:UIImageView?
    var colorIndicatorView:UIView?
    var slidingView:UIView?
    var activeView:UIView?
    
    // MARK: - Initialziers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
        setup()
    }
    

    private func setup()
    {
        setupDefaults()
        
        // Setup Gesture Recognizer.
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGestureRecognizer:")
        self.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
    }
    
    private func setupDefaults()
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
        // Depending on the state we assign the attributes
        if (state  == .State1) {
            completionBlock1 = completionBlock;
            view1 = view;
            color1 = color;
            modeForState1 = mode;
        }
        
        if (state == .State2) {
            completionBlock2 = completionBlock;
            view2 = view;
            color2 = color;
            modeForState2 = mode;
        }
        
        if (state == .State3) {
            completionBlock3 = completionBlock;
            view3 = view;
            color3 = color;
            modeForState3 = mode;
        }
        
        if (state  == .State4) {
            completionBlock4 = completionBlock;
            view4 = view;
            color4 = color;
            modeForState4 = mode;
        }

    }
    
    func swipeToOriginWithCompletion(completion:()->Void) {
        
        /*UIView.animateWithDuration(duration:animationDuration,
        delay:delay,
        usingSpringWithDamping: damping,
        initialSpringVelocity: velocity,
        options: .CurveEaseOut,*/
        
        UIView.animateWithDuration(animationDuration, delay:0, options:[UIViewAnimationOptions.CurveEaseOut, UIViewAnimationOptions.AllowUserInteraction],
            animations: { () -> Void in
                var frame = self.contentScreenshotView!.frame;
                frame.origin.x = 0;
                self.contentScreenshotView!.frame = frame
                
                // Clearing the indicator view
                self.colorIndicatorView!.backgroundColor = self.defaultColor
                
                self.slidingView!.alpha = 0;
                self.slideViewWithPercentage(0, view:self.activeView!, isDragging:false)
            }, completion: { (Bool) -> Void in
                
                self.isExited = false;
                self.uninstallSwipingView()
                
                completion();
                
        })
    }
    
    // MARK: - Private Methods
    
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        
        uninstallSwipingView()
        setupDefaults()
    }
    
    // MARK: - View Manipulation
    
    private func setupSwipingView()
    {
        if let _ = contentScreenshotView
        {
            return;
        }
        
        colorIndicatorView = UIView(frame: self.bounds)
        colorIndicatorView!.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        
        if let color = defaultColor
        {
            colorIndicatorView!.backgroundColor = color
        } else {
            colorIndicatorView!.backgroundColor = UIColor.clearColor()
        }
        
        addSubview(colorIndicatorView!)
    
        slidingView = UIView();
        slidingView!.contentMode = .Center
        colorIndicatorView!.addSubview(slidingView!)
    
        let contentViewScreenshotImage = imageWithView(self);
        contentScreenshotView = UIImageView(image: contentViewScreenshotImage)
        addSubview(contentScreenshotView!)
    }
    
    private func uninstallSwipingView() {
        if let _ = contentScreenshotView
        {
            slidingView!.removeFromSuperview()
            slidingView = nil;
            
            colorIndicatorView!.removeFromSuperview()
            colorIndicatorView = nil;
            
            self.contentScreenshotView!.removeFromSuperview()
            self.contentScreenshotView = nil;
        }

    }
    
    
    private func setViewOfSlidingView(newView:UIView?)
    {
        // remove old view
        if let slidingView = slidingView {
            
            for view:UIView in slidingView.subviews
            {
                view.removeFromSuperview()
            }
            
            // add new view
            slidingView.addSubview(newView!)
        }
    }
    
    
    func handlePanGestureRecognizer(gesture:UIPanGestureRecognizer )
    {
        if (!shouldDrag || isExited) {
            return
        }
        
        let state = gesture.state;
        let translation = gesture.translationInView(self)
        let velocity = gesture.velocityInView(self)
        
        var percentage:CGFloat = 0
        
        if let view = contentScreenshotView {
            percentage = percentageWithOffset(CGRectGetMinX(view.frame), relativeToWidth:CGRectGetWidth(self.bounds))
        }
        
        animationDuration = animationDurationWithVelocity(velocity)
        direction = directionWithPercentage(percentage)
        
        if state == .Began || state == .Changed {
            isDragging = true
            setupSwipingView()
            
            if let view = contentScreenshotView {
                
                view.frame.origin.x += translation.x;
                
                animateWithOffset(CGRectGetMinX(view.frame))
                gesture.setTranslation(CGPointZero, inView:self)
                
                // Notifying the delegate that we are dragging with an offset percentage.
                if let delegate = self.delegate {
                    delegate.swipeTableViewCell(self, didSwipeWithPercentage: percentage)
                }
            }
        }
    
        else if state == .Ended || state == .Cancelled {
            
            isDragging = false
            activeView = viewWithPercentage(percentage)
            currentPercentage = percentage;
            
            let cellState:TPTSwipeTableViewCellState = stateWithPercentage(percentage)
            var cellMode: TPTSwipeTableViewCellMode = .None
            
            if cellState == .State1 && modeForState1 != .None {
                cellMode = self.modeForState1;
            }
                
            else if cellState == .State2 && modeForState2 != .None {
                cellMode = self.modeForState2;
            }
                
            else if cellState == .State3 && modeForState3 != .None {
                cellMode = self.modeForState3;
            }
                
            else if cellState == .State4 && modeForState4 != .None {
                cellMode = self.modeForState4;
            }
            
            if (cellMode == .Exit && direction != .Center) {
                moveWithDuration(animationDuration, andDirection:direction)
            }
                
            else {
                swipeToOriginWithCompletion({
                    self.executeCompletionBlock()
                })
            }
            
            // We notify the delegate that we just ended swiping.
            if let delegate = self.delegate {
                delegate.swipeTableViewCellDidEndSwiping(self)
            }
        }
    }
    
    // MARK: - Movement
    
    private func animateWithOffset(offset:CGFloat) {
        let percentage = percentageWithOffset(offset, relativeToWidth:CGRectGetWidth(self.bounds))
        
        // View Position.
        if let view = viewWithPercentage(percentage) {
            setViewOfSlidingView(view)
            slidingView!.alpha = alphaWithPercentage(percentage)
            slideViewWithPercentage(percentage, view:view, isDragging:shouldAnimateIcons)
        }
        
        // Color
        let color = colorWithPercentage(percentage)
        colorIndicatorView!.backgroundColor = color
    }
    
    private func slideViewWithPercentage(percentage:CGFloat, view:UIView, isDragging:Bool)
    {
        var position = CGPointZero
        position.y = CGRectGetHeight(self.bounds) / 2.0;

        if isDragging {
            if (percentage >= 0 && percentage < firstTrigger) {
                position.x = offsetWithPercentage(firstTrigger / 2.0, relativeToWidth:CGRectGetWidth(self.bounds))
            }
                
            else if (percentage >= firstTrigger) {
                position.x = offsetWithPercentage(percentage - (firstTrigger / 2.0), relativeToWidth:CGRectGetWidth(self.bounds))
            }
                
            else if (percentage < 0 && percentage >= -firstTrigger) {
                position.x = CGRectGetWidth(self.bounds) - offsetWithPercentage(firstTrigger / 2.0, relativeToWidth:CGRectGetWidth(self.bounds))
            }
                
            else if (percentage < -firstTrigger) {
                position.x = CGRectGetWidth(self.bounds) + offsetWithPercentage(percentage + (firstTrigger / 2.0), relativeToWidth:CGRectGetWidth(self.bounds))
            }
        }
            
        else {
            if direction == .Right {
                position.x = offsetWithPercentage(firstTrigger / 2.0, relativeToWidth:CGRectGetWidth(self.bounds))
            }
                
            else if direction == .Left {
                position.x = CGRectGetWidth(self.bounds) - offsetWithPercentage(firstTrigger / 2.0, relativeToWidth:CGRectGetWidth(self.bounds))
            }
                
            else {
                return;
            }
        }
        
        let activeViewSize = view.bounds.size;
        var activeViewFrame = CGRectMake(position.x - activeViewSize.width / 2.0,
            position.y - activeViewSize.height / 2.0,
            activeViewSize.width,
            activeViewSize.height);
        
        activeViewFrame = CGRectIntegral(activeViewFrame);
        slidingView!.frame = activeViewFrame;
    }
    
    private func moveWithDuration(duration:NSTimeInterval, andDirection moveDirection:TPTSwipeTableViewCellDirection) {
        
        isExited = true
        var origin:CGFloat
        
        if (moveDirection == .Left) {
            origin = -CGRectGetWidth(self.bounds);
        }
            
        else if (moveDirection == .Right) {
            origin = CGRectGetWidth(self.bounds);
        }
            
        else {
            origin = 0;
        }
        
        let percentage = percentageWithOffset(origin, relativeToWidth:CGRectGetWidth(self.bounds))
        var frame = contentScreenshotView!.frame;
        frame.origin.x = origin;
        
        // Color
        let color = colorWithPercentage(currentPercentage)
        colorIndicatorView!.backgroundColor = color
        
        UIView.animateWithDuration(duration, delay:0, options:[UIViewAnimationOptions.CurveEaseOut, UIViewAnimationOptions.AllowUserInteraction], animations:{ () -> Void in
            self.contentScreenshotView!.frame = frame;
            self.slidingView!.alpha = 0;
            self.slideViewWithPercentage(percentage, view:self.activeView!, isDragging:self.shouldAnimateIcons)
            }, completion:{ (Bool) -> Void in
                self.executeCompletionBlock()
            })
    }
    


    // MARK: - Percentage
    
    private func offsetWithPercentage(percentage: CGFloat, relativeToWidth width:CGFloat) -> CGFloat
    {
        var offset:CGFloat = percentage * width;
        
        if offset < -width
        {
            offset = -width
        }
        else if offset > width
        {
            offset = width
        }
        return offset;
    }
    
    private func percentageWithOffset(offset:CGFloat, relativeToWidth width:CGFloat) -> CGFloat
    {
        var percentage:CGFloat = offset / width;
    
        if percentage < -1.0
        {
            percentage = -1.0
        }
        else if percentage > 1.0
        {
            percentage = 1.0
        }
        return percentage
    }
    
    private func animationDurationWithVelocity(velocity:CGPoint) -> NSTimeInterval
    {
        let width = CGRectGetWidth(self.bounds);
        let animationDurationDiff:NSTimeInterval = kMCDurationHighLimit - kMCDurationLowLimit
        var horizontalVelocity:CGFloat = velocity.x;
    
        if horizontalVelocity < -width
        {
            horizontalVelocity = -width
        }
        else if horizontalVelocity > width
        {
            horizontalVelocity = width
        }
    
        return NSTimeInterval(CGFloat(kMCDurationHighLimit + kMCDurationLowLimit) - fabs(((horizontalVelocity / width) * CGFloat(animationDurationDiff))));
    }
    
    private func directionWithPercentage(percentage:CGFloat) -> TPTSwipeTableViewCellDirection
    {
        if percentage < 0
        {
            return .Left
        }
        else if percentage > 0
        {
            return .Right
        }
        else
        {
            return .Center
        }
    }
    
    private func viewWithPercentage(percentage:CGFloat) -> UIView?
    {
        
        var view:UIView?
        
        if percentage >= 0 && modeForState1 != .None {
            view = view1
        }
        
        if percentage >= secondTrigger && modeForState2 != .None {
            view = view2
        }
        
        if percentage < 0  && modeForState3 != .None {
            view = view3
        }
        
        if percentage <= -secondTrigger && modeForState4 != .None {
            view = view4;
        }
        
        return view;
    }
    
    private func alphaWithPercentage(percentage:CGFloat) -> CGFloat {
        var alpha:CGFloat
        
        if percentage >= 0 && percentage < firstTrigger
        {
            alpha = percentage / firstTrigger;
        }
        else if percentage < 0 && percentage > -firstTrigger
        {
            alpha = fabs(percentage / firstTrigger);
        }
        else
        {
            alpha = 1.0;
        }
        
        return alpha;
    }
    
    private func colorWithPercentage(percentage:CGFloat) -> UIColor {
        var color:UIColor
    
        // Background Color
        if let defaultColor = defaultColor
        {
            color = defaultColor
        } else {
            color = UIColor.clearColor()
        }
        
        if  percentage > firstTrigger && modeForState1 != .None {
            color = color1;
        }
        
        if percentage > secondTrigger && modeForState2 != .None {
            color = color2;
        }
        
        if percentage < -firstTrigger && modeForState3 != .None {
            color = color3;
        }
        
        if percentage <= -secondTrigger && modeForState4 != .None {
            color = color4;
        }
        
        return color
    }
    
    private func stateWithPercentage(percentage:CGFloat) -> TPTSwipeTableViewCellState
    {
        var state:TPTSwipeTableViewCellState = .StateNone;
        
        if percentage >= firstTrigger && modeForState1 != .None {
            state = .State1
        }
        
        if percentage >= secondTrigger && modeForState2 != .None {
            state = .State2
        }
        
        if percentage <= -firstTrigger && modeForState3 != .None {
            state = .State3
        }
        
        if percentage <= -secondTrigger && modeForState4 != .None {
            state = .State4
        }
        
        return state
    }
    
    
    
    // MARK: - Utilities
    
    private func imageWithView(view:UIView) -> UIImage
    {
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scale);
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    
    // MARK: - Completion block
    
    private func executeCompletionBlock() {
        let state = stateWithPercentage(currentPercentage)
        var mode = TPTSwipeTableViewCellMode.None
        var completionBlock:TPTSwipeCompletionBlock?
        
        switch (state) {
        case .State1:
            mode = self.modeForState1;
            completionBlock = completionBlock1!
            break;
            
        case .State2:
            mode = self.modeForState2;
            completionBlock = completionBlock2;
            break;
            
        case .State3:
            mode = self.modeForState3;
            completionBlock = completionBlock3;
            break;
            
        case .State4:
            mode = self.modeForState4;
            completionBlock = completionBlock4;
            break;
            
        default:
            break;
        }
        
        if let block = completionBlock {
            block(self, state, mode);
        }
        
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    override func gestureRecognizerShouldBegin(gestureRecognizer:UIGestureRecognizer) -> Bool {
        
        if (gestureRecognizer.isKindOfClass(UIPanGestureRecognizer)) {
            
            let gesture:UIPanGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
            
            let point = gesture.velocityInView(self)
            
            if (fabs(point.x) > fabs(point.y) ) {
                
                if (point.x < 0 && modeForState3 == .None && modeForState4 == .None) {
                    return false
                }
                
                if (point.x > 0 && modeForState1 == .None && modeForState2 == .None) {
                    return false
                }
                
                // We notify the delegate that we just started dragging
                if let delegate = self.delegate {
                    delegate.swipeTableViewCellDidStartSwiping(self)
                }
                
                return true
            }
        }
        
        return false
    }
    
}
