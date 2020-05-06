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
被邀请主播ID和名称
 */
@property (copy, nonatomic) NSString *inviteAnchorId;
@property (copy, nonatomic) NSString *inviteAnchorName;

/**
推荐主播的ID和名称
*/
@property (copy, nonatomic) NSString *recommendAnchorId;
@property (copy, nonatomic) NSString *recommendAnchorName;

@end
