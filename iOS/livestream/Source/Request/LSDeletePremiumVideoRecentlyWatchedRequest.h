//
//  LSDeletePremiumVideoRecentlyWatchedRequest.h
//  dating
//  18.7.删除最近播放的视频
//  Created by Alex on 20/08/05
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSDeletePremiumVideoRecentlyWatchedRequest : LSSessionRequest

//记录ID(列表返回的watched_id值，多个用’,’号分隔)
@property (nonatomic, copy) NSString* _Nonnull watchedId;
@property (nonatomic, strong) DeletePremiumVideoRecentlyWatchedFinishHandler _Nullable finishHandler;
@end
