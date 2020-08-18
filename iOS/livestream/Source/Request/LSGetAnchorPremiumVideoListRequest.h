//
//  LSGetAnchorPremiumVideoListRequest.h
//  dating
//  18.12.获取某主播的视频列表
//  Created by Alex on 20/08/04
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetAnchorPremiumVideoListRequest : LSSessionRequest

//主播ID
@property (nonatomic, copy) NSString* _Nonnull anchorId;
@property (nonatomic, strong) GetAnchorPremiumVideoListFinishHandler _Nullable finishHandler;
@end
