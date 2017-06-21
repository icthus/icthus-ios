//
//  SlideFromLeftPresentationController.swift
//  
//
//  Created by Matthew Lorentz on 6/21/17.
//

class SlideFromLeftPresentationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    @objc var presenting = true
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let finalFrameForVC = transitionContext.finalFrame(for: toViewController)
        let containerView = transitionContext.containerView
        let bounds = UIScreen.main.bounds
        
        if presenting {
            toViewController.view.frame = finalFrameForVC.offsetBy(dx: -bounds.size.width, dy: 0)
            containerView.addSubview(toViewController.view)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                toViewController.view.frame = finalFrameForVC
            }) { (_) in
                transitionContext.completeTransition(true)
            }
        } else {
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                fromViewController.view.frame = finalFrameForVC.offsetBy(dx: -bounds.size.width, dy: 0)
            }) { (_) in
                transitionContext.completeTransition(true)
            }
        }
    }
}
