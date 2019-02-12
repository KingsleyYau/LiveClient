//
//  LSGetRecentContactAnchorRequest.h
//  dating
//  8.7.获取Hang-out列表
//  Created by Alex on 18/1/21
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetRecentContactAnchorRequest : LSSessionRequest
@property (nonatomic, strong) GetRecentContactAnchorFinishHandler _Nullable finishHandler;
@end
