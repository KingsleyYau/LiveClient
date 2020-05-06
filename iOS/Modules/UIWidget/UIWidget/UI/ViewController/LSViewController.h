//
//  LSViewController.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSColor.h"
@interface LSViewController : UIViewController
@property (strong) NSString* backTitle;
@property (strong) UIView *loadActivityView;
@property (strong) NSString *navigationTitle;

/**
 界面是否第一次显示
 */
@property (assign, readonly) BOOL viewDidAppearEver;
/**
 界面是否正在显示
 */
@property (assign, readonly) BOOL viewIsAppear;

#pragma mark - 导航栏状态
/**
 是否显示导航栏
 */
@property (assign) BOOL isShowNavBar;
/**
 隐藏导航栏状态下，是否隐藏后退按钮
 */
@property (assign) BOOL isHideNavBackButton;
/**
 显示导航栏状态下，是否隐藏导航栏下划线
 */
@property (assign) BOOL isHideNavBottomLine;
/**
 是否能通过手势返回
 */
@property (assign) BOOL canPopWithGesture;
/**
 是否加载强制更新状态栏
 */
@property (assign) BOOL isUpdateStatusBar;

#pragma mark - 横屏切换
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (BOOL)shouldAutorotate;
- (UIInterfaceOrientationMask)supportedInterfaceOrientations;

#pragma mark - 界面布局
/**
 *  初始化
 */
- (void)initCustomParam;
/**
 *  反初始化
 */
- (void)dealloc;
/**
 *  初始化导航栏
 */
- (void)setupNavigationBar;
/**
 *  初始化界面约束
 */
- (void)setupContainView;
/**
 *  显示加载状态
 */
- (void)showLoading;
/**
 *  隐藏加载状态
 */
- (void)hideLoading;

/**
 *  重设和隐藏加载状态(为了防止之前的showLoading 和 hideLoading 没有一一对应，重新设置)
 */
-(void)hideAndResetLoading;

/**
 *  重设和显示加载状态(为了防止之前的showLoading 和 hideLoading 没有一一对应，重新设置)
 */
- (void)showAndResetLoading;
- (void)reloadLoadingActivityViewFrame;
/**
 <#Description#>

 @param sender <#sender description#>
 */
- (void)backAction:(id)sender;

#pragma mark - 导航栏隐藏处理
- (void)showNavigationBar;
- (void)hideNavigationBar;
- (void)setNavigationBackButtonHidden:(BOOL)isHide;
- (void)setNavgationBarBottomLineHidden:(BOOL)isHide;
- (void)setNavigationBackgroundAlpha:(CGFloat)alpha;

#pragma mark - 导航跳转处理
- (NSString *)identification;
- (BOOL)isSameVC:(LSViewController *)vc;

@end
