//
//  LiveNotificationService.h
//  livestream
//
//  Created by test on 2018/10/11.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INotificationsService.h"
@interface LiveNotificationService : NSObject<INotificationsServiceService>
+ (instancetype)service;
@end
