//
//  KKViewController.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKViewController : UIViewController
@property (nonatomic, assign) BOOL viewDidAppearEver;
@property (nonatomic, strong) NSString* backTitle;
@property (nonatomic, strong) UIView *loadActivityView;
@property (nonatomic, strong) NSString *navigationTitle;

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
 *  初始化界面
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

- (void)hideNavgationBarBottomLine;

/**
 *  重设和隐藏加载状态
 */
-(void)hideAndResetLoading;

/**
 *  重设和显示加载状态
 */
- (void)showAndResetLoading;

/**
 *  设置导航栏返回按钮样式
 */
- (void)setBackleftBarButtonItemOffset:(CGFloat)offset;

@end
