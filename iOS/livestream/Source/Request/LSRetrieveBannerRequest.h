//
//  LSRetrieveBannerRequest.h
//  dating
//  6.24.获取直播广告
//  Created by Alex on 19/08/08
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSRetrieveBannerRequest : LSSessionRequest

/**
 *  6.24.获取直播广告接口
 *
 * manId                         用户ID
 * sAnchorPage                  是否是是主播详情页
 * bannerType                    邀請類型(LSBANNERTYPE_NINE_SQUARED:直播站内九宫格 LSBANNERTYPE_ALL_BROADCASTERS:All Broadcasters LSBANNERTYPE_FEATURED_BROADCASTERS:Featured Broadcasters LSBANNERTYPE_SAYHI:Say Hi LSBANNERTYPE_GREETMAIL:Greeting Mail LSBANNERTYPE_MAIL:Mail LSBANNERTYPE_CHAT:Chat LSBANNERTYPE_HANGOUT:Hang-out LSBANNERTYPE_GIFTSFLOWERS:Gifts & Flowers)
 *  finishHandler    接口回调s
 */
@property (nonatomic, copy) NSString* _Nonnull manId;
@property (nonatomic, assign) BOOL isAnchorPage;
@property (nonatomic, assign) LSBannerType bannerType;
@property (nonatomic, strong) RetrieveBannerFinishHandler _Nullable finishHandler;
@end
