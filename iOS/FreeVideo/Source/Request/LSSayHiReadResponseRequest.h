//
//  LSSayHiReadResponseRequest.h
//  dating
//  14.8.获取SayHi回复详情接口
//  Created by Alex on 19/4/19
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSSayHiReadResponseRequest : LSSessionRequest
/**
 * sayHiId                         sayHi的ID
 */
@property (nonatomic, copy) NSString* _Nullable sayHiId;
/**
 * responseId                         回复ID
 */
@property (nonatomic, copy) NSString* _Nullable responseId;

@property (nonatomic, strong) ReadResponseFinishHandler _Nullable finishHandler;
@end
