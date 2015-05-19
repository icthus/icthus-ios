//
//  SwipingLeftImageView.swift
//  Icthus
//
//  Created by Matthew Lorentz on 5/19/15.
//  Copyright (c) 2015 Matthew Lorentz. All rights reserved.
//

import UIKit

@objc class SwipingLeftImageView: UIImageView, AnimatedImageView {
    
    private enum AnimationState {
        case Resting
        case Dragging
        case TextReturning
        case TouchReturning
    }
    
    private let restingTime = 0.8
    private let draggingTime = 1.5
    private let textReturningTime = 0.45
    private let touchReturningTime = 0.8
    
    private var shouldAnimate = false
    
    private let touchIconHoveringName = "Touch Icon Hover"
    private let touchIconPressedName = "Touch Icon Pressed"
    private var touchIconHovering : UIImageView?
    private var touchIconPressed : UIImageView?
    
    private var touchIconRestingLocation : CGPoint?
    private var touchIconDragDestination : CGPoint?
    
    // drag distance should be just enough to display the verses
    private var dragDistance : CGFloat = 60
    
    override init(image: UIImage!) {
        super.init(image: image)
        setup()
    }
    
    override init(image: UIImage!, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        // create the touchIcon
        touchIconHovering = UIImageView(image: UIImage(named:touchIconHoveringName))
        touchIconPressed = UIImageView(image: UIImage(named: touchIconPressedName))
        
        // touchIcon should rest in the center of the image
        touchIconRestingLocation = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        
        
        // drag destination should be the resting location minus the dragDistance
        touchIconDragDestination = CGPoint(x: touchIconRestingLocation!.x - dragDistance, y: touchIconRestingLocation!.y)
    }

    func startAnimation() {
        shouldAnimate = true
        self.addSubview(touchIconHovering!)
        self.addSubview(touchIconPressed!)
        runAnimationWithState(.Resting)
    }
    
    func stopAnimation() {
        shouldAnimate = false
        self.touchIconHovering!.removeFromSuperview()
        self.touchIconPressed!.removeFromSuperview()
    }
    
    private func runAnimationWithState(state : AnimationState) {
        if !shouldAnimate {
            return
        }
        
        // The animation works like a simple finite state machine
        switch state {
        case .Resting:
            
            touchIconHovering!.center = touchIconRestingLocation!
            touchIconPressed!.hidden = true

            
            nextState(.Dragging, afterDelay: restingTime)
        case .Dragging:
            
            touchIconHovering?.hidden = true
            touchIconPressed?.hidden = false
            touchIconPressed?.center = touchIconRestingLocation!
            
            UIView.animateWithDuration(draggingTime, animations: { () -> Void in
                self.frame.origin.x = self.frame.origin.x - self.dragDistance
            })
            
            nextState(.TextReturning, afterDelay: draggingTime)
        case .TextReturning:
            
            touchIconHovering?.hidden = false
            touchIconPressed?.hidden = true
            
            UIView.animateWithDuration(textReturningTime, animations: { () -> Void in
                self.frame.origin.x = self.frame.origin.x + self.dragDistance
                self.touchIconHovering!.frame.origin.x -= self.dragDistance
            })
            
            nextState(.TouchReturning, afterDelay: textReturningTime)
        
        case .TouchReturning:
            UIView.animateWithDuration(touchReturningTime, animations: { () -> Void in
                self.touchIconHovering!.frame.origin.x += self.dragDistance
            })
            
            nextState(.Resting, afterDelay: touchReturningTime)
        }
    }
    
    private func nextState(nextState: AnimationState, afterDelay: Double) {
        let continuation = {
            self.runAnimationWithState(nextState)
        }
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(afterDelay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(),
            continuation
        )
    }
}
