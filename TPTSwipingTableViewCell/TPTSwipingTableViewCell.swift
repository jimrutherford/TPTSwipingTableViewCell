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
    
    // MARK: - Constants
    let kMCBounceDuration1:NSTimeInterval      = 0.2;  // Duration of the first part of the bounce animation
    let kMCBounceDuration2:NSTimeInterval      = 0.1;  // Duration of the second part of the bounce animation
    let kMCDurationLowLimit:NSTimeInterval     = 0.25; // Lowest duration when swiping the cell because we try to simulate velocity
    let kMCDurationHighLimit:NSTimeInterval    = 0.1;  // Highest duration when swiping the cell because we try to simulate velocity
    
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
    
    var animationDuration:NSTimeInterval = 0.4
    var damping = 0.6
    var velocity = 0.9
    
    var firstTrigger:CGFloat = 0.25
    var secondTrigger:CGFloat = 0.75
    
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
    var colorIndicatorView:UIView?
    var slidingView:UIView?
    var activeView:UIView?
    
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
        // Depending on the state we assign the attributes
        if (state  == .State4) {
            completionBlock1 = completionBlock;
            view1 = view;
            color1 = color;
            modeForState1 = mode;
        }
        
        if (state == .State4) {
            completionBlock2 = completionBlock;
            view2 = view;
            color2 = color;
            modeForState2 = mode;
        }
        
        if (state == .State4) {
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
    
    //- (void)swipeToOriginWithCompletion:(void(^)(void))completion;
    
    
    // MARK: - Private Methods
    
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        
        uninstallSwipingView()
        setupDefaults()
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
    
        contentScreenshotView = UIImageView(image: contentViewScreenshotImage)
        addSubview(contentScreenshotView!)
    }
    
    func uninstallSwipingView() {
        if let _ = contentScreenshotView
        {
            return;
        }
        
        slidingView!.removeFromSuperview()
        slidingView = nil;
        
        colorIndicatorView!.removeFromSuperview()
        colorIndicatorView = nil;
        
        contentScreenshotView!.removeFromSuperview()
        contentScreenshotView = nil;
    }
    
    
    func setViewOfSlidingView(newView:UIView?)
    {
        // remove old view
        if let slidingView = slidingView {
            
            for view:UIView in slidingView.subviews
            {
                view.removeFromSuperview()
            }
        }
        
        // add new view
        slidingView?.addSubview(newView!)
    }
    
    
    func handlePanGestureRecognizer(gesture:UIPanGestureRecognizer )
    {
        
        if (!shouldDrag || isExited) {
            return
        }
        
        let state = gesture.state;
        let translation = gesture.translationInView(self)
        let velocity = gesture.velocityInView(self)
        let percentage = percentageWithOffset(CGRectGetMinX(contentScreenshotView!.frame), relativeToWidth:CGRectGetWidth(self.bounds))
        animationDuration = animationDurationWithVelocity(velocity)
        direction = directionWithPercentage(percentage)
        
        
        if state == .Began || state == .Changed {
            isDragging = true
            
            setupSwipingView()
            
            center = CGPoint(x: contentScreenshotView!.center.x + translation.x, y: contentScreenshotView!.center.y)
            contentScreenshotView!.center = center;
            animateWithOffset(CGRectGetMinX(contentScreenshotView!.frame))
            gesture.setTranslation(CGPointZero, inView:self)
            
            // Notifying the delegate that we are dragging with an offset percentage.
            if let delegate = self.delegate {
                delegate.swipeTableViewCell(self, didSwipeWithPercentage: percentage)
            }

        }
    
        else if state == .Ended || state == .Cancelled {
            
            isDragging = false
            activeView = viewWithPercentage(percentage)
            currentPercentage = percentage;
            
            var cellState:TPTSwipeTableViewCellState = stateWithPercentage(percentage)
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
                [self swipeToOriginWithCompletion:^{
                    [self executeCompletionBlock];
                    }];
            }
            
            // We notify the delegate that we just ended swiping.
            if let delegate = self.delegate {
                delegate.swipeTableViewCellDidEndSwiping(self)
            }
            
        }
    }
    
    // MARK: - Movement
    
    func animateWithOffset(offset:CGFloat) {
        let percentage = percentageWithOffset(offset, relativeToWidth:CGRectGetWidth(self.bounds))
        
        let view = viewWithPercentage(percentage)
        
        // View Position.
        if let view = view {
            setViewOfSlidingView(view)
            slidingView!.alpha = alphaWithPercentage(percentage)
            slideViewWithPercentage(percentage, view:view, isDragging:shouldAnimateIcons)
        }
        
        // Color
        let color = colorWithPercentage(percentage)
        
        colorIndicatorView!.backgroundColor = color
        
    }
    
    func slideViewWithPercentage(percentage:CGFloat, view:UIView, isDragging:Bool)
    {
        var position = CGPointZero
        position.y = CGRectGetHeight(self.bounds) / 2.0;
        
        if isDragging {
            if (percentage >= 0 && percentage < firstTrigger) {
                position.x = offsetWithPercentage((firstTrigger / 2), relativeToWidth:CGRectGetWidth(self.bounds))
            }
                
            else if (percentage >= firstTrigger) {
                position.x = offsetWithPercentage(percentage - (firstTrigger / 2), relativeToWidth:CGRectGetWidth(self.bounds))
            }
                
            else if (percentage < 0 && percentage >= -firstTrigger) {
                position.x = CGRectGetWidth(self.bounds) - offsetWithPercentage((firstTrigger / 2), relativeToWidth:CGRectGetWidth(self.bounds))
            }
                
            else if (percentage < -firstTrigger) {
                position.x = CGRectGetWidth(self.bounds) + offsetWithPercentage(percentage + (firstTrigger / 2), relativeToWidth:CGRectGetWidth(self.bounds))
            }
        }
            
        else {
            if direction == .Right {
                position.x = offsetWithPercentage((firstTrigger / 2), relativeToWidth:CGRectGetWidth(self.bounds))
            }
                
            else if direction == .Left {
                position.x = CGRectGetWidth(self.bounds) - offsetWithPercentage((firstTrigger / 2), relativeToWidth:CGRectGetWidth(self.bounds))
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
    
    func moveWithDuration(duration:NSTimeInterval, andDirection moveDirection:TPTSwipeTableViewCellDirection) {
        
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
       
        UIView.animateWithDuration(duration, delay:0, options:(.CurveEaseOut | .AllowUserInteraction), animations:{ () -> Void in
            contentScreenshotView.frame = frame;
            slidingView.alpha = 0;
            slideViewWithPercentage(percentage, view:activeView, isDragging:shouldAnimateIcons)
            }, completion:{ (Bool) -> Void in
                executeCompletionBlock()
            })

    }
    
    - (void)swipeToOriginWithCompletion:(void(^)(void))completion {
    CGFloat bounceDistance = kMCBounceAmplitude * _currentPercentage;
    
    if ([UIView.class respondsToSelector:@selector(animateWithDuration:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:)]) {
    
    [UIView animateWithDuration:_animationDuration delay:0.0 usingSpringWithDamping:_damping initialSpringVelocity:_velocity options:UIViewAnimationOptionCurveEaseInOut animations:^{
    
    CGRect frame = _contentScreenshotView.frame;
    frame.origin.x = 0;
    _contentScreenshotView.frame = frame;
    
    // Clearing the indicator view
    _colorIndicatorView.backgroundColor = self.defaultColor;
    
    _slidingView.alpha = 0;
    [self slideViewWithPercentage:0 view:_activeView isDragging:NO];
    
    } completion:^(BOOL finished) {
    
    _isExited = NO;
    [self uninstallSwipingView];
    
    if (completion) {
    completion();
    }
    }];
    }
    
    else {
    [UIView animateWithDuration:kMCBounceDuration1 delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
    
    CGRect frame = _contentScreenshotView.frame;
    frame.origin.x = -bounceDistance;
    _contentScreenshotView.frame = frame;
    
    _slidingView.alpha = 0;
    [self slideViewWithPercentage:0 view:_activeView isDragging:NO];
    
    // Setting back the color to the default.
    _colorIndicatorView.backgroundColor = self.defaultColor;
    
    } completion:^(BOOL finished1) {
    
    [UIView animateWithDuration:kMCBounceDuration2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
    
    CGRect frame = _contentScreenshotView.frame;
    frame.origin.x = 0;
    _contentScreenshotView.frame = frame;
    
    // Clearing the indicator view
    _colorIndicatorView.backgroundColor = [UIColor clearColor];
    
    } completion:^(BOOL finished2) {
    
    _isExited = NO;
    [self uninstallSwipingView];
    
    if (completion) {
    completion();
    }
    }];
    }];
    }
    }

    // MARK: - Percentage
    
    func offsetWithPercentage(percentage: CGFloat, relativeToWidth width:CGFloat) -> CGFloat
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
    
    func percentageWithOffset(offset:CGFloat, relativeToWidth width:CGFloat) -> CGFloat
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
    
    func animationDurationWithVelocity(velocity:CGPoint) -> NSTimeInterval
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
    
    func directionWithPercentage(percentage:CGFloat) -> TPTSwipeTableViewCellDirection
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
    
    func viewWithPercentage(percentage:CGFloat) -> UIView?
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
    
    func alphaWithPercentage(percentage:CGFloat) -> CGFloat {
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
    
    func colorWithPercentage(percentage:CGFloat) -> UIColor {
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
    
    func stateWithPercentage(percentage:CGFloat) -> TPTSwipeTableViewCellState
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
    
    func imageWithView(view:UIView) -> UIImage
    {
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scale);
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    
    // MARK: - Completion block
    
    func executeCompletionBlock() {
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
    
}
