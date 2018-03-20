//
//  AppDelegate.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

#define AppDelegate() ((AppDelegate *)[UIApplication sharedApplication].delegate)

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    NSUncaughtExceptionHandler *_handler;
}

@property (strong, nonatomic) UIWindow *window;

/**
 *  是否Demo环境(允许注销)
 */
@property (nonatomic, assign, readonly) BOOL demo;

/**
 *  调试模式, 正式环境是否允许注销(YES:允许注销/NO:不允许注销)
 */
@property (nonatomic, assign, readonly) BOOL debug;

/**
 *  是否在后台
 */
@property (nonatomic, assign) BOOL isBackground;

/*是否有网络*/
@property (nonatomic, assign) BOOL isNetwork;

/**
 *  设置接口请求环境
 *
 *  @param formal 是否正式环境
 */
- (void)setRequestHost:(BOOL)formal;

@end

