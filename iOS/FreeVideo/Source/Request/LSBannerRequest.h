//
//  LSBannerRequest.h
//  dating
//  6.9.获取Hot/Following列表头部广告
//  Created by Alex on 17/10/19
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSBannerRequest : LSSessionRequest

@property (nonatomic, strong) BannerFinishHandler _Nullable finishHandler;
@end
