//
//  SwipingLeftImageView.swift
//  Icthus
//
//  Created by Matthew Lorentz on 5/19/15.
//  Copyright (c) 2015 Matthew Lorentz. All rights reserved.
//

import UIKit

@objc class SwipingLeftImageView: UIImageView, AnimatedImageView {
    
    fileprivate enum AnimationState {
        case resting
        case dragging
        case textReturning
        case touchReturning
    }
    
    fileprivate let restingTime = 0.8
    fileprivate let draggingTime = 1.5
    fileprivate let textReturningTime = 0.45
    fileprivate let touchReturningTime = 0.8
    
    fileprivate var shouldAnimate = false
    
    fileprivate let touchIconHoveringName = "Touch Icon Hover"
    fileprivate let touchIconPressedName = "Touch Icon Pressed"
    fileprivate var touchIconHovering : UIImageView?
    fileprivate var touchIconPressed : UIImageView?
    
    fileprivate var touchIconRestingLocation : CGPoint?
    fileprivate var touchIconDragDestination : CGPoint?
    
    // drag distance should be just enough to display the verses
    fileprivate var dragDistance : CGFloat = 60
    
    fileprivate func setup() {
        // create the touchIcon
        touchIconHovering = UIImageView(image: UIImage(named:touchIconHoveringName))
        touchIconPressed = UIImageView(image: UIImage(named: touchIconPressedName))
        
        // touchIcon should rest in the center of the image
        touchIconRestingLocation = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        
        
        // drag destination should be the resting location minus the dragDistance
        touchIconDragDestination = CGPoint(x: touchIconRestingLocation!.x - dragDistance, y: touchIconRestingLocation!.y)
    }

    func startAnimation() {
        setup()
        shouldAnimate = true
        self.addSubview(touchIconHovering!)
        self.addSubview(touchIconPressed!)
        runAnimationWithState(.resting)
    }
    
    func stopAnimation() {
        shouldAnimate = false
        self.touchIconHovering!.removeFromSuperview()
        self.touchIconPressed!.removeFromSuperview()
    }
    
    fileprivate func runAnimationWithState(_ state : AnimationState) {
        if !shouldAnimate {
            return
        }
        
        // The animation works like a simple finite state machine
        switch state {
        case .resting:
            
            touchIconHovering!.center = touchIconRestingLocation!
            touchIconPressed!.isHidden = true

            
            nextState(.dragging, afterDelay: restingTime)
        case .dragging:
            
            touchIconHovering?.isHidden = true
            touchIconPressed?.isHidden = false
            touchIconPressed?.center = touchIconRestingLocation!
            
            UIView.animate(withDuration: draggingTime, animations: { () -> Void in
                self.frame.origin.x = self.frame.origin.x - self.dragDistance
            })
            
            nextState(.textReturning, afterDelay: draggingTime)
        case .textReturning:
            
            touchIconHovering?.isHidden = false
            touchIconPressed?.isHidden = true
            
            UIView.animate(withDuration: textReturningTime, animations: { () -> Void in
                self.frame.origin.x = self.frame.origin.x + self.dragDistance
                self.touchIconHovering!.frame.origin.x -= self.dragDistance
            })
            
            nextState(.touchReturning, afterDelay: textReturningTime)
        
        case .touchReturning:
            UIView.animate(withDuration: touchReturningTime, animations: { () -> Void in
                self.touchIconHovering!.frame.origin.x += self.dragDistance
            })
            
            nextState(.resting, afterDelay: touchReturningTime)
        }
    }
    
    fileprivate func nextState(_ nextState: AnimationState, afterDelay: Double) {
        let continuation = {
            self.runAnimationWithState(nextState)
        }
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(afterDelay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: continuation
        )
    }
}
