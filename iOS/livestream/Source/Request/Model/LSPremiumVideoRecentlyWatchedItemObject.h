//
//  LSPremiumVideoRecentlyWatchedItemObject
//  dating
//
//  Created by Alex on 20/08/05.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSPremiumVideoinfoItemObject.h"
@interface LSPremiumVideoRecentlyWatchedItemObject : NSObject
/**
 * 最近播放的视频信息结构体
 * watchedId                    记录ID
 * premiumVideoInfo     付费视频信息
 * addTime          添加时间(GMT时间戳)
 */
@property (nonatomic, copy) NSString* watchedId;
@property (nonatomic, strong) LSPremiumVideoinfoItemObject* premiumVideoInfo;
@property (nonatomic, assign) NSInteger addTime;

@end
