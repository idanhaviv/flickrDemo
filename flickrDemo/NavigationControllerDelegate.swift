//
//  NavigationControllerDelegate.swift
//  flickrDemo
//
//  Created by idan haviv on 7/4/15.
//  Copyright (c) 2015 idan haviv. All rights reserved.
//

import UIKit

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {

    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CircleTransitionAnimator()
    }
}
