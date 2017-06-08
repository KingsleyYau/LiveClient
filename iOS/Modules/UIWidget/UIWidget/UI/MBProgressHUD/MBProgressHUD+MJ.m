//
//  MBProgressHUD+MJ.m
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD+MJ.h"

@implementation MBProgressHUD (MJ)

#pragma mark - MBProgressHUD 自动消失
/**
 *  加载进度条 MBProgressHUD自动消失（title，message其一可为空）
 */
+ (void)showMessageWithTitle:(NSString *)title message:(NSString *)message toView:(UIView *)view {
    
    // afterDelay之后再消失
    [MBProgressHUD showMessageWithTitle:title message:message toView:view afterDelay:3];
}

+ (void)showMessageWindow:(NSString *)title {
    
//    [MBProgressHUD showMessage:title toView:[YMAppDelegate sharedObject].window];
}

+ (void)showMessageWithTitle:(NSString *)title message:(NSString *)message toView:(UIView *)view afterDelay:(float)afterDelay {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = title;
    hud.detailsLabelText = message;
    hud.labelFont = [UIFont boldSystemFontOfSize:14.0];
    hud.detailsLabelFont = [UIFont systemFontOfSize:12.0];
    hud.yOffset = ([[UIScreen mainScreen] bounds].size.height) * 0.2;
    // 再设置模式
    hud.mode = MBProgressHUDModeText;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // afterDelay之后再消失
    [hud hide:YES afterDelay:afterDelay];
}

/**
 *  显示提示 MBProgressHUD自动消失（title，message其一可为空）
 */
+ (void)showTipsWithTitle:(NSString *)title {
    [MBProgressHUD showTipsWithTitle:title message:nil toView:nil];
}

+ (void)showTipsWithMessage:(NSString *)message {
    [MBProgressHUD showTipsWithTitle:nil message:message toView:nil];
}

+ (void)showTipsWithTitle:(NSString *)title message:(NSString *)message  toView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = title;
    hud.detailsLabelText = message;
    hud.labelFont = [UIFont boldSystemFontOfSize:14.0];
    hud.detailsLabelFont = [UIFont systemFontOfSize:12.0];
    
    // 再设置模式
    hud.mode = MBProgressHUDModeText;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 2秒之后再消失
    [hud hide:YES afterDelay:kHUDFadeAnimationTime];
}

#pragma mark - 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"error.png" view:view];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"success.png" view:view];
}

#pragma mark - 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = text;
    hud.labelFont = [UIFont systemFontOfSize:14];
    
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 2秒之后再消失
    [hud hide:YES afterDelay:kHUDFadeAnimationTime];
}

#pragma mark - 显示一些信息
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = message;
    hud.labelFont = [UIFont systemFontOfSize:14];
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // YES代表需要蒙版效果
//    hud.dimBackground = YES;
    
    return hud;
}

//只有文字,会回收
+ (void)showInfo:(NSString *)info{
    
    [self show:info icon:@"" view:nil];
    
    
}


+ (void)showSuccess:(NSString *)success
{
    [self showSuccess:success toView:nil];
}

+ (void)showError:(NSString *)error
{
    [self showError:error toView:nil];
}

+ (MBProgressHUD *)showMessage:(NSString *)message
{
    return [self showMessage:message toView:nil];
}

+ (void)hideHUDForView:(UIView *)view
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    
    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD
{
    [self hideHUDForView:nil];
}

+ (void)hideHUDWindow {
//    [self hideHUDForView:[YMAppDelegate sharedObject].window];
}
@end
