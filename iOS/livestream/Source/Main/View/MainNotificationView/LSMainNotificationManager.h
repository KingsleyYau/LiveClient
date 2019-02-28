//
//  LSMainNotificationManager.h
//  livestream
//
//  Created by Calvin on 2019/1/17.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LSMainNotificationManagerDelegate <NSObject>

- (void)mainNotificationManagerShowNotificaitonView;

- (void)mainNotificationManagerHideNotificaitonView;

- (void)mainNotificationManagerRemoveNotificaitonView;

@end

@interface LSMainNotificationManager : NSObject

+ (instancetype)manager;

@property (strong, readonly) NSArray * items;

@property (nonatomic, assign) CGFloat timeOutNum;

@property (nonatomic, weak) id<LSMainNotificationManagerDelegate> delegate;

- (void)selectedShowArrayRow:(NSInteger)row;
@end


