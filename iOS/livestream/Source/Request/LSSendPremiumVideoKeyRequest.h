//
//  LSSendPremiumVideoKeyRequest.h
//  dating
//  18.4.发送解码锁请求
//  Created by Alex on 20/08/04
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSSendPremiumVideoKeyRequest : LSSessionRequest

//视频ID
@property (nonatomic, copy) NSString* _Nonnull videoId;
@property (nonatomic, strong) SendPremiumVideoKeyRequestFinishHandler _Nullable finishHandler;
@end
