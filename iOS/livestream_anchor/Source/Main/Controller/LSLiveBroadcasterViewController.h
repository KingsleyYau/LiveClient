//
//  LSLiveBroadcasterViewController.h
//  livestream_anchor
//
//  Created by test on 2018/2/27.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGoogleAnalyticsViewController.h"
#import "LiveRoom.h"
@interface LSLiveBroadcasterViewController : LSGoogleAnalyticsViewController
@property (nonatomic, assign) NSInteger curIndex;
- (void)getUnreadSheduledBooking;
@end
