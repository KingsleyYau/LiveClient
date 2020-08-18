//
//  LSPremiumRequestListItemObject.h
//  livestream
//
//  Created by Albert on 2020/7/29.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Premium Video Request 列表
 * videoid          视频ID
 * title         视频标题
 * inviteid         邀请ID
 * video_cover            视频图片
 * video_url           视频url
 * sendTime         发送时间戳（1970年起的秒数）
 * video_total_time         视频总时长
 * has_read      是否已读（0：否，1：是）
 */
@interface LSPremiumRequestListItemObject : NSObject
@property (nonatomic, copy) NSString *videoid;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *inviteid;
@property (nonatomic, copy) NSString *video_cover;
@property (nonatomic, copy) NSString *video_url;
@property (nonatomic, assign) NSInteger sendTime;
@property (nonatomic, assign) CGFloat video_total_time;
@property (nonatomic, assign) NSInteger has_read;
@property (nonatomic, assign) NSInteger is_fav;
@end

NS_ASSUME_NONNULL_END
