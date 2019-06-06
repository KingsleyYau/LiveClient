//
//  LSSayHiIsCanSendRequest.h
//  dating
//  14.3.检测能否对指定主播发送SayHi（用于检测能否对指定主播发送SayHi，观众端暂无用到本接口）
//  Created by Alex on 19/4/19
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSSayHiIsCanSendRequest : LSSessionRequest
/**
 * anchorId                         主播ID
 */
@property (nonatomic, copy) NSString* _Nullable anchorId;
@property (nonatomic, strong) IsCanSendSayHiFinishHandler _Nullable finishHandler;
@end
