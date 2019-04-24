//
//  LSLCRecentVideoItemObject.h
//  dating
//
//  Created by Calvin on 19/3/15.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSLCRecentVideoItemObject : NSObject

/** 视频ID */
@property (nonatomic,copy) NSString *videoId;
/** 视频标题*/
@property (nonatomic,copy) NSString *title;
/** 邀请ID */
@property (nonatomic,copy) NSString *inviteid;
/** 视频URL */
@property (nonatomic,copy) NSString *videoUrl;
/** 视频图片（对应《12.14.获取微视频图片》的“大图”） */
@property (nonatomic,copy) NSString *videoCover;

- (LSLCRecentVideoItemObject *)init;


@end
