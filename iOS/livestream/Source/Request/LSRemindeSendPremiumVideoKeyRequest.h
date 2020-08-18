//
//  LSRemindeSendPremiumVideoKeyRequest.h
//  dating
//  18.5.发送解码锁请求提醒
//  Created by Alex on 20/08/04
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSRemindeSendPremiumVideoKeyRequest : LSSessionRequest

//请求ID
@property (nonatomic, copy) NSString* _Nonnull requestId;
@property (nonatomic, strong) RemindeSendPremiumVideoKeyRequestFinishHandler _Nullable finishHandler;
@end
