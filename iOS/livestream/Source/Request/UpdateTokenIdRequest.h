//
//  UpdateTokenIdRequest.h
//  dating
//  2.3.上传tokenid接口
//  Created by Alex on 17/8/17.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface UpdateTokenIdRequest : SessionRequest
// 用于Push Notification的ID
@property (nonatomic, strong) NSString* _Nullable tokenId;
@property (nonatomic, strong) UpdateTokenIdFinishHandler _Nullable finishHandler;
@end
