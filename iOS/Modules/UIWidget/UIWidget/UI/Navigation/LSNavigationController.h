//
//  LSNavigationController.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LSNavigationControllerDelegate <NSObject>
@optional
// Called when the navigation controller shows a new top view controller via a push, pop or setting of the view controller stack.
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)backAction;
@end

@interface LSNavigationController : UINavigationController {
}
@property (nonatomic, assign) IBOutlet id<LSNavigationControllerDelegate> kkDelegate;
@property (nonatomic, retain) UIImage *customDefaultBackImage;
@property (nonatomic, retain) NSString *customDefaultBackTitle;
@property (atomic, assign) BOOL canReceiveTouch;
@property (nonatomic, strong) UIImage *customDefaultBackHighlightImage;
/** 在present的控制器上会调用多一次dismiss,用于判断是否需要dismiss的,默认是正常dissmiss的 */
@property (nonatomic, assign) BOOL flag;

/**
 *  加入栈之前先添加手势
 *
 *  @param viewController viewController
 *  @param animated       是否需要动画
 *  @param gesture        是否使用手势
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated gesture:(BOOL)gesture;

/**
 用于present界面弹出拍照之后,当前present的界面无法消失的问题
 @param  是否强制
 */
- (void)forceToDismissAnimated:(BOOL)flag completion:(void (^)(void))completion;

@end

@interface UIViewController (LSNavigationControllerNavigationBarItem)
@property (nonatomic, strong) NSString *customBackTitle;
@end

