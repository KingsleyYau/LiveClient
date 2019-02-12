//
//  LSChatViewController.h
//  livestream
//
//  Created by Calvin on 2018/6/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGoogleAnalyticsViewController.h"
#import "LSPrivateMessageManager.h"

@interface LSChatViewController : LSGoogleAnalyticsViewController

typedef void (^GetLocalMessage)();

+ (instancetype)initChatVCWithAnchorId:(NSString *)anchorId;

@end
