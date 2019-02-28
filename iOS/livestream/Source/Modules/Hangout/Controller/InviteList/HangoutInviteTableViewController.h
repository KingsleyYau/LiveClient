//
//  HangoutInviteTableViewController.h
//  livestream
//
//  Created by Max on 2018/5/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LSGoogleAnalyticsViewController.h"

#import "LSRequestManager.h"

@interface HangoutInviteAnchor : NSObject
@property (nonatomic, strong) NSString *anchorId;
@property (nonatomic, strong) NSString *anchorName;
@property (nonatomic, strong) NSString *photoUrl;
@end

@class HangoutInviteTableViewController;
@protocol HangoutInviteDelegate <NSObject>
@optional
- (void)didHangoutInviteAnchor:(HangoutInviteAnchor *)item;
@end

@interface HangoutInviteTableViewController : LSGoogleAnalyticsViewController
@property (nonatomic, strong) NSString *anchorId;
@property (nonatomic, weak) id<HangoutInviteDelegate> inviteDelegate;
// 刷新新数据
- (void)reloadInviteList;
@end
