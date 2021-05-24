//
//  AppDelegate.h
//  RtmpClientTest
//
//  Created by Max on 2017/4/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#define AppShareDelegate() ((AppDelegate *)[UIApplication sharedApplication].delegate)

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) BOOL subscribed;
@property (nonatomic) BOOL firstTimeActive;
@property (nonatomic) BOOL pornhubActive;
@property (nonatomic) BOOL tvActive;
@end

