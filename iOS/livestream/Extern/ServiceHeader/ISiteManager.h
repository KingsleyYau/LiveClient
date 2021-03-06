//
//  ISiteManager.h
//  dating
//  换站管理器接口类
//  Created by Max on 2018/7/17.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//


#ifndef ISiteManager_h
#define ISiteManager_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 换站管理器接口类
 */
@protocol ISiteManager <NSObject>

/**
 选站回调
 */
typedef void (^DidSelectItemHandler)();

#pragma mark - 手动点击显示选站
/**
 在指定界面控制器显示选站对话框
 
 @param vc 指定界面控制器
 */
- (UIViewController *)showDialogInViewController:(UIViewController *)vc handler:(DidSelectItemHandler)handler;

#pragma mark - 左边划出界面选站列表
/**
 站点列表界面

 @param vc 指定界面控制器
 @param view 指定界面
 */
- (UIViewController *)showTableInViewController:(UIViewController *)vc view:(UIView *)view handler:(DidSelectItemHandler)handler;
/**
 站点列表界面高度

 @return 站点列表高度
 */
- (NSInteger)siteTableHeight;
/**
 关闭换站界面

 @param vc 界面控制器
 */
- (void)closeViewController:(UIViewController *)vc;

@end

#endif
