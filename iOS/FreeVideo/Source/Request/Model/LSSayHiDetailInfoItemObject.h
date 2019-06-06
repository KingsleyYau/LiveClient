//
//  LSSayHiDetailInfoItemObject.h
//  dating
//
//  Created by Alex on 19/4/18.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSayHiDetailItemObject.h"
#import "LSSayHiDetailResponseListItemObject.h"
/**
 * SayHi详情
 * detail           详情
 * responseList     sayHi回复列表
 */
@interface LSSayHiDetailInfoItemObject : NSObject
@property (nonatomic, strong) LSSayHiDetailItemObject* detail;
@property (nonatomic, strong) NSMutableArray<LSSayHiDetailResponseListItemObject *>* responseList;

@end
