//
//  LSGetPremiumVideoTypeListRequest.h
//  dating
//  18.1.获取付费视频分类列表
//  Created by Alex on 20/08/03
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetPremiumVideoTypeListRequest : LSSessionRequest

@property (nonatomic, strong) GetPremiumVideoTypeListFinishHandler _Nullable finishHandler;
@end
