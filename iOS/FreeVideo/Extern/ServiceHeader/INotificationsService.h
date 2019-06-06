//
//  INotificationsService.h
//  dating
//
//  Created by test on 2018/10/11.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#ifndef INotificationsService_h
#define INotificationsService_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol INotificationsServiceService <NSObject>

- (void)parseNotificationUrl:(NSURL *)url;

#endif /* INotificationsService_h */
@end
