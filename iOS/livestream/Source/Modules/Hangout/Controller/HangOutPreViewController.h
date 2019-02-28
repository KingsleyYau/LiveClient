//
//  HangOutPreViewController.h
//  livestream
//
//  Created by Randy_Fan on 2018/5/2.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveRoom.h"
#import "LSGoogleAnalyticsViewController.h"
@interface HangOutPreViewController : LSGoogleAnalyticsViewController

/**
 私密直播间跳转时才有值
 */
@property (copy, nonatomic) NSString *roomId;

/**
 好友推荐跳转时 为被推荐人主播ID和名称
 非好友推荐跳转时 为被邀请主播ID和名称
 */
@property (copy, nonatomic) NSString *inviteAnchorId;
@property (copy, nonatomic) NSString *inviteAnchorName;

/**
 推荐好友时使用 (推荐人ID和名称)
 */
@property (copy, nonatomic) NSString *hangoutAnchorId;
@property (copy, nonatomic) NSString *hangoutAnchorName;

@end
