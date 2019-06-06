//
// LSFollowShowRequest.h
//  dating
//  9.4.关注/取消关注请求
//  Created by Max on 18/04/18.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSFollowShowRequest : LSSessionRequest
/**
 *  9.4.关注/取消关注节目接口
 *
 *  liveShowId       节目ID
 *  isCancle         是否取消
 *  finishHandler    接口回调
 *
 */
@property (nonatomic, copy) NSString * _Nullable liveShowId;
@property (nonatomic, assign) BOOL isCancle;
@property (nonatomic, strong) FollowShowFinishHandler _Nullable finishHandler;
@end
