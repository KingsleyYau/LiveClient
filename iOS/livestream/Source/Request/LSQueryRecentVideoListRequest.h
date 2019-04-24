//
//  LSQueryRecentVideoListRequest.h
//  dating
//  12.13.获取最近已看微视频列表
//  Created by Alex on 19/3/22
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"
#import "LSLiveChatRequestManager.h"

@interface LSQueryRecentVideoListRequest : LSSessionRequest
// 登录成功返回的sessionid
@property (nonatomic, copy) NSString* _Nullable userSid;
// 登录成功返回的manid
@property (nonatomic, copy) NSString* _Nullable userId;
// 主播ID
@property (nonatomic, copy) NSString* _Nullable womanId;
@property (nonatomic, strong) QueryRecentVideoListFinishHandler _Nullable finishHandler;
@end
