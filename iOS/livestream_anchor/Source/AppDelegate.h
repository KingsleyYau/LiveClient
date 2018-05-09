//
//  AppDelegate.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ZBAppDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    NSUncaughtExceptionHandler *_handler;
}

@property (strong, nonatomic) UIWindow *window;

/**
 *  是否Demo环境(允许注销)
 */
@property (nonatomic, assign, readonly) BOOL demo;

/**
 *  是否在后台
 */
@property (nonatomic, assign) BOOL isBackground;

/*是否有网络*/
@property (nonatomic, assign) BOOL isNetwork;
@end

