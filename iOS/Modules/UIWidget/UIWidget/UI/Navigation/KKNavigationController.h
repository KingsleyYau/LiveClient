//
//  KKNavigationController.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KKNavigationControllerDelegate <NSObject>
@optional
// Called when the navigation controller shows a new top view controller via a push, pop or setting of the view controller stack.
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)backAction;
@end


@interface KKNavigationController : UINavigationController {

}
@property (nonatomic, assign) IBOutlet id<KKNavigationControllerDelegate> kkDelegate;
@property (nonatomic, retain) UIImage* customDefaultBackImage;
@property (nonatomic, retain) NSString* customDefaultBackTitle;
@property (atomic, assign) BOOL canReceiveTouch;
@property (nonatomic,strong) UIImage* customDefaultBackHighlightImage;

/**
 *  加入栈之前先添加手势
 *
 *  @param viewController viewController
 *  @param animated       是否需要动画
 *  @param gesture        是否使用手势
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated gesture:(BOOL)gesture;

@end

@interface UIViewController (KKNavigationControllerNavigationBarItem)
@property (nonatomic, strong) NSString* customBackTitle;
@end

