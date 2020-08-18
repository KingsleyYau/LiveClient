//
//  LSDeleteInterestedPremiumVideoRequest.h
//  dating
//  18.9.删除收藏的视频
//  Created by Alex on 20/08/04
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSDeleteInterestedPremiumVideoRequest : LSSessionRequest

//视频ID
@property (nonatomic, copy) NSString* _Nonnull videoId;
@property (nonatomic, strong) DeleteInterestedPremiumVideoFinishHandler _Nullable finishHandler;
@end
