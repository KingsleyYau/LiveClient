//
//  LSGetHangoutStatusRequest.h
//  dating
//  8.11.获取当前会员Hangout直播状态
//  Created by Alex on 19/1/23
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetHangoutStatusRequest : LSSessionRequest
@property (nonatomic, strong) GetHangoutStatusFinishHandler _Nullable finishHandler;
@end
