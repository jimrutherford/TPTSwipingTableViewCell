//
//  TPTSwipingTableViewCell.swift
//  TPTSwipingTableViewCell
//
//  Created by Jim Rutherford on 2015-07-30.
//  Copyright © 2015 Braxio Interactive. All rights reserved.
//

import UIKit

struct TPTSwipeCellAction {
    var iconName:String
    var color:UIColor
    var trigger:CGFloat
    var mode: TPTSwipeTableViewCellMode
    var completionBlock:TPTSwipeCompletionBlock?
}

enum TPTSwipeTableViewCellMode:Int {
    case None = 0
    case Exit = 1
    case Switch = 2
}

enum TPTSwipeTableViewCellDirection:Int {
    case LeftToRight = 0
    case None = 1
    case RightToLeft = 2
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

typealias TPTSwipeCompletionBlock = (TPTSwipingTableViewCell, TPTSwipeTableViewCellMode) -> Void


class TPTSwipingTableViewCell: UITableViewCell {
    
    // MARK: - Constants
    let kMCBounceDuration1:NSTimeInterval      = 0.2  // Duration of the first part of the bounce animation
    let kMCBounceDuration2:NSTimeInterval      = 0.1  // Duration of the second part of the bounce animation
    let kMCDurationLowLimit:NSTimeInterval     = 0.25 // Lowest duration when swiping the cell because we try to simulate velocity
    let kMCDurationHighLimit:NSTimeInterval    = 0.1  // Highest duration when swiping the cell because we try to simulate velocity
    let kMCBounceAmplitude:CGFloat = 20.0 // Maximum bounce amplitude when using the MCSwipeTableViewCellModeSwitch mode
    
    // MARK: - Public/Internal Properties
    
    var delegate: TPTSwipingTableViewCellDelegate?
    
    var actionItemsLeft = [TPTSwipeCellAction]()
    var actionItemsRight = [TPTSwipeCellAction]()
    
    var defaultColor:UIColor?
    
    var animationDuration:NSTimeInterval = 0.4
    var damping = 0.6
    var velocity = 0.9
    
    var isDragging = false
    var shouldDrag = true
    var shouldAnimateIcons = true
    
    @IBOutlet weak var myLabel: UILabel!
    
    // MARK: - Private properties
    var direction:TPTSwipeTableViewCellDirection = .None
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
        
        damping = 0.6
        velocity = 0.9
        animationDuration = 0.4
        
        defaultColor = UIColor.whiteColor()
    }

    
    func swipeToOriginWithCompletion(completion:()->Void) {
        
        /*UIView.animateWithDuration(duration:animationDuration,
        delay:delay,
        usingSpringWithDamping: damping,
        initialSpringVelocity: velocity,
        options: .CurveEaseOut,*/
        
        UIView.animateWithDuration(animationDuration, delay:0, options:[UIViewAnimationOptions.CurveEaseOut, UIViewAnimationOptions.AllowUserInteraction],
            animations: { () -> Void in
                var frame = self.contentScreenshotView!.frame
                frame.origin.x = 0
                self.contentScreenshotView!.frame = frame
                
                // Clearing the indicator view
                self.colorIndicatorView!.backgroundColor = self.defaultColor
                
                self.slidingView!.alpha = 0
                self.slideViewWithPercentage(0, view:self.activeView!, isDragging:false)
            }, completion: { (Bool) -> Void in
                
                self.isExited = false
                self.uninstallSwipingView()
                
                completion()
                
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
            return
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
    
        slidingView = UIView()
        slidingView!.contentMode = .Center
        colorIndicatorView!.addSubview(slidingView!)
    
        let contentViewScreenshotImage = imageWithView(self)
        contentScreenshotView = UIImageView(image: contentViewScreenshotImage)
        addSubview(contentScreenshotView!)
    }
    
    private func uninstallSwipingView() {
        if let _ = contentScreenshotView
        {
            slidingView!.removeFromSuperview()
            slidingView = nil
            
            colorIndicatorView!.removeFromSuperview()
            colorIndicatorView = nil
            
            self.contentScreenshotView!.removeFromSuperview()
            self.contentScreenshotView = nil
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
        
        let state = gesture.state
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
                
                view.frame.origin.x += translation.x
                
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
            currentPercentage = percentage
            
            if let cellAction:TPTSwipeCellAction = cellActionWithPercentage(percentage)
            {
                if (cellAction.mode == .Exit && direction != .None) {
                    moveWithDuration(animationDuration, andDirection:direction)
                }
                    
                else {
                    swipeToOriginWithCompletion({
                        self.executeCompletionBlock()
                    })
                }
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
        position.y = CGRectGetHeight(self.bounds) / 2.0

        let trigger = firstTrigger()
        
        if isDragging {
            if (percentage >= 0 && percentage < trigger) {
                position.x = offsetWithPercentage(trigger / 2.0, relativeToWidth:CGRectGetWidth(self.bounds))
            }
                
            else if (percentage >= trigger) {
                position.x = offsetWithPercentage(percentage - (trigger / 2.0), relativeToWidth:CGRectGetWidth(self.bounds))
            }
                
            else if (percentage < 0 && percentage >= -trigger) {
                position.x = CGRectGetWidth(self.bounds) - offsetWithPercentage(trigger / 2.0, relativeToWidth:CGRectGetWidth(self.bounds))
            }
                
            else if (percentage < -trigger) {
                position.x = CGRectGetWidth(self.bounds) + offsetWithPercentage(percentage + (trigger / 2.0), relativeToWidth:CGRectGetWidth(self.bounds))
            }
        }
            
        else {
            if direction == .RightToLeft {
                position.x = offsetWithPercentage(trigger / 2.0, relativeToWidth:CGRectGetWidth(self.bounds))
            }
                
            else if direction == .LeftToRight {
                position.x = CGRectGetWidth(self.bounds) - offsetWithPercentage(trigger / 2.0, relativeToWidth:CGRectGetWidth(self.bounds))
            }
                
            else {
                return
            }
        }
        
        let activeViewSize = view.bounds.size
        var activeViewFrame = CGRectMake(position.x - activeViewSize.width / 2.0,
            position.y - activeViewSize.height / 2.0,
            activeViewSize.width,
            activeViewSize.height)
        
        activeViewFrame = CGRectIntegral(activeViewFrame)
        slidingView!.frame = activeViewFrame
    }
    
    private func moveWithDuration(duration:NSTimeInterval, andDirection moveDirection:TPTSwipeTableViewCellDirection) {
        
        isExited = true
        var origin:CGFloat
        
        if (moveDirection == .LeftToRight) {
            origin = -CGRectGetWidth(self.bounds)
        }
            
        else if (moveDirection == .RightToLeft) {
            origin = CGRectGetWidth(self.bounds)
        }
            
        else {
            origin = 0
        }
        
        let percentage = percentageWithOffset(origin, relativeToWidth:CGRectGetWidth(self.bounds))
        var frame = contentScreenshotView!.frame
        frame.origin.x = origin
        
        // Color
        let color = colorWithPercentage(currentPercentage)
        colorIndicatorView!.backgroundColor = color
        
        UIView.animateWithDuration(duration, delay:0, options:[UIViewAnimationOptions.CurveEaseOut, UIViewAnimationOptions.AllowUserInteraction], animations:{ () -> Void in
            self.contentScreenshotView!.frame = frame
            self.slidingView!.alpha = 0
            self.slideViewWithPercentage(percentage, view:self.activeView!, isDragging:self.shouldAnimateIcons)
            }, completion:{ (Bool) -> Void in
                self.executeCompletionBlock()
            })
    }
    


    // MARK: - Percentage
    
    private func offsetWithPercentage(percentage: CGFloat, relativeToWidth width:CGFloat) -> CGFloat
    {
        var offset:CGFloat = percentage * width
        
        if offset < -width
        {
            offset = -width
        }
        else if offset > width
        {
            offset = width
        }
        return offset
    }
    
    private func percentageWithOffset(offset:CGFloat, relativeToWidth width:CGFloat) -> CGFloat
    {
        var percentage:CGFloat = offset / width
    
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
        let width = CGRectGetWidth(self.bounds)
        let animationDurationDiff:NSTimeInterval = kMCDurationHighLimit - kMCDurationLowLimit
        var horizontalVelocity:CGFloat = velocity.x
    
        if horizontalVelocity < -width
        {
            horizontalVelocity = -width
        }
        else if horizontalVelocity > width
        {
            horizontalVelocity = width
        }
    
        return NSTimeInterval(CGFloat(kMCDurationHighLimit + kMCDurationLowLimit) - fabs(((horizontalVelocity / width) * CGFloat(animationDurationDiff))))
    }
    
    private func directionWithPercentage(percentage:CGFloat) -> TPTSwipeTableViewCellDirection
    {
        if percentage < 0
        {
            return .LeftToRight
        }
        else if percentage > 0
        {
            return .RightToLeft
        }

        return .None

    }
    
    private func viewWithPercentage(percentage:CGFloat) -> UIView?
    {
        if let cellAction = cellActionWithPercentage(percentage)
        {
            return viewWithImageName(cellAction.iconName)
        }
        
        return nil
    }
    
    private func alphaWithPercentage(percentage:CGFloat) -> CGFloat {
        let trigger = firstTrigger()
        
        var alpha:CGFloat
        
        if percentage >= 0 && percentage < trigger
        {
            alpha = percentage / trigger
        }
        else if percentage < 0 && percentage > -trigger
        {
            alpha = fabs(percentage / trigger)
        }
        else
        {
            alpha = 1.0
        }
        
        return alpha
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
        
        if let cellAction = cellActionWithPercentage(percentage)
        {
            if (percentage > cellAction.trigger)
            {
                color = cellAction.color
            }
        }
        
        return color
    }
    
    private func cellActionWithPercentage(percentage:CGFloat) -> TPTSwipeCellAction?
    {
        
        let sorted:Array<TPTSwipeCellAction> = actionItemsLeft.sort{ $0.trigger < $1.trigger }
        
        // get first that is < percentage
        
        let filtered = sorted.filter{$0.trigger < percentage}
        
        if let result = filtered.last
        {
            print("\(percentage) - \(result.iconName)")
            return result
        }
        
        if let result = sorted.first
        {
            print("\(percentage) - \(result.iconName)")
            return result
        }
        
        print("NOTHING")
        return nil
        
    }
    
    
    private func firstTrigger() -> CGFloat
    {
        let sorted:Array<TPTSwipeCellAction> = actionItemsLeft.sort{ $0.trigger < $1.trigger }
        
        if let result = sorted.first
        {
            return result.trigger
        }
        
        return 0.0
    }
    
    // MARK: - Utilities
    
    private func imageWithView(view:UIView) -> UIImage
    {
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scale)
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func viewWithImageName(imageName:String) -> UIView {
        let image = UIImage(named:imageName)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .Center
        return imageView
    }
    
    // MARK: - Completion block
    
    private func executeCompletionBlock() {
        if let cellAction = cellActionWithPercentage(currentPercentage)
        {
            if let block = cellAction.completionBlock {
                block(self, cellAction.mode)
            }
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    override func gestureRecognizerShouldBegin(gestureRecognizer:UIGestureRecognizer) -> Bool {
        
        if (gestureRecognizer.isKindOfClass(UIPanGestureRecognizer)) {
            
            let gesture:UIPanGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
            
            let point = gesture.velocityInView(self)
            
            if (fabs(point.x) > fabs(point.y) ) {
                /*
                if (point.x < 0 && modeForState3 == .None && modeForState4 == .None) {
                    return false
                }
                
                if (point.x > 0 && modeForState1 == .None && modeForState2 == .None) {
                    return false
                }
                */
                
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
