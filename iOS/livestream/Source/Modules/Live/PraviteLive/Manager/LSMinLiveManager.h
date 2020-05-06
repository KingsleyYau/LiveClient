//
//  LSMinLiveManager.h
//  livestream
//
//  Created by Calvin on 2019/11/12.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSMinLiveView.h"

@protocol LSMinLiveManagerDelegate <NSObject>

- (void)pushMaxLive;
@end

@interface LSMinLiveManager : NSObject

@property (nonatomic, strong) LSMinLiveView * minView;
@property (nonatomic, copy) NSString * userId;
@property (nonatomic, strong) UIViewController * liveVC;
@property (nonatomic, weak) id<LSMinLiveManagerDelegate> delegate;
+ (instancetype)manager;

- (void)setMinViewAddVC:(UIViewController *)vc;
- (void)showMinLive;
- (void)hidenMinLive;
- (void)minLiveViewDidCloseBtn;
- (void)removeVC;
@end

 
