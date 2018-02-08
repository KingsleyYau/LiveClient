//
//  LSViewController.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSViewController : UIViewController
@property (nonatomic, assign) BOOL viewDidAppearEver;
@property (nonatomic, strong) NSString* backTitle;
@property (nonatomic, strong) UIView *loadActivityView;
@property (nonatomic, strong) NSString *navigationTitle;
@property (nonatomic, assign) BOOL viewIsAppear;

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
 *  初始化控件
 */
- (void)initialiseSubwidge;

/**
 *  显示加载状态
 */
- (void)showLoading;
/**
 *  隐藏加载状态
 */
- (void)hideLoading;

- (void)hideNavgationBarBottomLine:(BOOL)isHide;

/**
 *  重设和隐藏加载状态(为了防止之前的showLoading 和 hideLoading 没有一一对应，重新设置)
 */
-(void)hideAndResetLoading;

/**
 *  重设和显示加载状态(为了防止之前的showLoading 和 hideLoading 没有一一对应，重新设置)
 */
- (void)showAndResetLoading;

/**
 *  设置导航栏返回按钮样式
 */
- (void)setBackleftBarButtonItemOffset:(CGFloat)offset;

- (void)backAction:(id)sender;

@end
