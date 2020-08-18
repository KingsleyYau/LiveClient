//
//  LSGetPremiumVideoDetailRequest.h
//  dating
//  18.13.获取视频详情
//  Created by Alex on 20/08/03
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetPremiumVideoDetailRequest : LSSessionRequest

//视频ID
@property (nonatomic, copy) NSString* _Nonnull videoId;
@property (nonatomic, strong) GetPremiumVideoDetailFinishHandler _Nullable finishHandler;
@end
