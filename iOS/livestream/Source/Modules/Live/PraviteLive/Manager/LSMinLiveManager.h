//
//  LSMinLiveManager.h
//  livestream
//
//  Created by Calvin on 2019/11/12.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSMinLiveView.h"
#import "PrivateViewController.h"
#import "PublicVipViewController.h"

@protocol LSMinLiveManagerDelegate <NSObject>

- (void)pushMaxLive;

@end

@interface LSMinLiveManager : NSObject

@property (nonatomic, strong) LSMinLiveView * minView;
@property (nonatomic, strong) PrivateViewController * privateLiveVC;
@property (nonatomic, strong) PublicVipViewController * publicLiveVC;
@property (nonatomic, weak) id<LSMinLiveManagerDelegate> delegate;
+ (instancetype)manager;

- (void)setMinViewAddVC:(UIViewController *)vc;
- (void)showMinLive;
- (void)hidenMinLive;
@end

 
