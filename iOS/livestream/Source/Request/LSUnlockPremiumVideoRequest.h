//
//  LSUnlockPremiumVideoRequest.h
//  dating
//  18.14.18.14.视频解锁
//  Created by Alex on 20/08/05
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSUnlockPremiumVideoRequest : LSSessionRequest

//解锁方式（LSUNLOCKACTIONTYPE_CREDIT：信用点解锁，LSUNLOCKACTIONTYPE_KEY：解锁码解锁
@property (nonatomic, assign) LSUnlockActionType type;
//解锁码(type=LSUNLOCKACTIONTYPE_KEY时传值)
@property (nonatomic, copy) NSString* _Nullable accessKey;
//视频ID
@property (nonatomic, copy) NSString* _Nonnull videoId;
@property (nonatomic, strong) UnlockPremiumVideoFinishHandler _Nullable finishHandler;
@end
