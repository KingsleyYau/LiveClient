//
//  LSMainNotificationManager.h
//  livestream
//
//  Created by Calvin on 2019/1/17.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSMainNotificaitonModel.h"

@protocol LSMainNotificationManagerDelegate <NSObject>

- (void)mainNotificationManagerShowNotificaitonView:(LSMainNotificaitonModel *)model;

- (void)mainNotificationManagerHideNotificaitonView:(LSMainNotificaitonModel *)model;

- (void)mainNotificationManagerRemoveNotificaitonView;

@end

@interface LSMainNotificationManager : NSObject

+ (instancetype)manager;

@property (nonatomic, assign) CGFloat timeOutNum;

@property (nonatomic, weak) id<LSMainNotificationManagerDelegate> delegate;

- (void)selectedShowArrayRowItem:(LSMainNotificaitonModel*)item;
@end


