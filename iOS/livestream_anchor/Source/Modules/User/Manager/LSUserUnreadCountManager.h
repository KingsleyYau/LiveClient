//
//  LSUserUnreadCountManager.h
//  livestream
//
//  Created by Calvin on 17/10/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSAnchorRequestManager.h"

@protocol LSUserUnreadCountManagerDelegate <NSObject>
@optional;
- (void)onGetUnreadSheduledBooking:(int)count;
- (void)onGetUnreadShowCalendar:(int)count;
@end

@interface LSUserUnreadCountManager : NSObject

+(instancetype _Nonnull)shareInstance;

/**
 *  增加监听器
 *
 *  @param delegate 监听器
 */
- (void)addDelegate:(id<LSUserUnreadCountManagerDelegate> _Nonnull)delegate;

/**
 *  移除监听器
 *
 *  @param delegate 监听器
 */
- (void)removeDelegate:(id<LSUserUnreadCountManagerDelegate> _Nonnull)delegate;

- (void)getResevationsUnredCount;
- (void)getUnreadSheduledBooking;
- (void)getUnreadShowCalendar;

@end
