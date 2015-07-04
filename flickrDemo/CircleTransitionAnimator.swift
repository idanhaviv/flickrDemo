//
//  CircleTransitionAnimator.swift
//  flickrDemo
//
//  Created by idan haviv on 7/4/15.
//  Copyright (c) 2015 idan haviv. All rights reserved.
//

import UIKit

class CircleTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
   
    weak var transitionContext: UIViewControllerContextTransitioning?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 1.2
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        self.transitionContext = transitionContext
        
        var containerView = transitionContext.containerView()
        var fromViewController: UIViewController
        var toViewController: UIViewController
        
        if let thumbnailPhotosVCisFromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? ViewController
        {
            fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! ViewController
            toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! PhotoViewController
        }
        else
        {
            fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! PhotoViewController
            toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! ViewController
        }
        
        var view = fromViewController.view
        containerView.addSubview(toViewController.view)
        
        var circleMaskPathInitial = UIBezierPath(ovalInRect: view.frame)
        var extremePoint = CGPoint(x: view.center.x - 0, y: view.center.y - CGRectGetHeight(toViewController.view.bounds))
        var radius = sqrt((extremePoint.x*extremePoint.x) + (extremePoint.y*extremePoint.y))
        var circleMaskPathFinal = UIBezierPath(ovalInRect: CGRectInset(view.frame, -radius, -radius))
        
        var maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.CGPath
        toViewController.view.layer.mask = maskLayer
        
        var maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = circleMaskPathInitial.CGPath
        maskLayerAnimation.toValue = circleMaskPathFinal.CGPath
        maskLayerAnimation.duration = self.transitionDuration(transitionContext)
        maskLayerAnimation.delegate = self
        maskLayer.addAnimation(maskLayerAnimation, forKey: "path")
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        self.transitionContext?.completeTransition(!self.transitionContext!.transitionWasCancelled())
        self.transitionContext?.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view.layer.mask = nil
    }
}
