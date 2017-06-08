//
//  MBProgressHUD+MJ.h
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD.h"

#define kHUDFadeAnimationTime 2.0f // HUD动画消失时间
#define kLoginHUDFadeAnimationTime 10.0f // HUD动画消失时间

@interface MBProgressHUD (MJ)
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;

+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;

+ (MBProgressHUD *)showMessage:(NSString *)message;

+ (void)hideHUDForView:(UIView *)view;
+ (void)hideHUD;
+ (void)hideHUDWindow;

//只有文字,会回收
+ (void)showInfo:(NSString *)info;

/**
 永远显示在第一次层（window）
 
 @param title title
 */
+ (void)showMessageWindow:(NSString *)title;

/**
 加载进度条 MBProgressHUD自动消失（title，message其一可为空）

 @param title      提示标题信息
 @param message    信息副标题
 @param view       目标视图（可为空）
 @param afterDelay 默认3s
 */
+ (void)showMessageWithTitle:(NSString *)title message:(NSString *)message toView:(UIView *)view afterDelay:(float)afterDelay;
+ (void)showMessageWithTitle:(NSString *)title message:(NSString *)message toView:(UIView *)view;


/**
 显示提示 MBProgressHUD(默认3s)自动消失（title，message其一可为空）

 @param title   提示标题信息
 @param message 信息副标题
 @param view    目标视图（可为空
 */
+ (void)showTipsWithTitle:(NSString *)title message:(NSString *)message toView:(UIView *)view;
+ (void)showTipsWithTitle:(NSString *)title;
+ (void)showTipsWithMessage:(NSString *)message;

@end
