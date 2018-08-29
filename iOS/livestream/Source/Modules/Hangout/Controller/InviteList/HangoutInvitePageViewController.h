//
//  HangoutInvitePageViewController.h
//  livestream
//
//  Created by Max on 2018/5/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HangoutInviteTableViewController.h"
#import "LSGoogleAnalyticsViewController.h"

@interface HangoutInvitePageViewController : LSGoogleAnalyticsViewController
@property (nonatomic, strong) NSArray<HangoutInviteAnchor *> *anchorIdArray;
@property (nonatomic, weak) id<HangoutInviteDelegate> inviteDelegate;
- (void)reloadData;
@end
