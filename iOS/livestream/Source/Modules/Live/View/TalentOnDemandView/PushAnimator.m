//
//  PushAnimator.m
//  testApp
//
//  Created by Max on 2018/5/25.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "PushAnimator.h"

@implementation PushAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *view = [transitionContext containerView];
    [view addSubview:toViewController.view];
    
    fromViewController.view.alpha = 1.0;
    fromViewController.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    
    toViewController.view.alpha = 1;
    toViewController.view.frame = CGRectMake(view.frame.size.width, 0, view.frame.size.width, view.frame.size.height);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         fromViewController.view.alpha = 1.0;
                         fromViewController.view.frame = CGRectMake(-view.frame.size.width, 0, view.frame.size.width, view.frame.size.height);
                         
                         toViewController.view.alpha = 1.0;
                         toViewController.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}

@end

@implementation PopAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *view = [transitionContext containerView];
    [view insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    fromViewController.view.alpha = 1.0;
    fromViewController.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    
    toViewController.view.alpha = 1;
    toViewController.view.frame = CGRectMake(-view.frame.size.width, 0, view.frame.size.width, view.frame.size.height);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         fromViewController.view.alpha = 1.0;
                         fromViewController.view.frame = CGRectMake(view.frame.size.width, 0, view.frame.size.width, view.frame.size.height);
                         
                         toViewController.view.alpha = 1.0;
                         toViewController.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}

@end
