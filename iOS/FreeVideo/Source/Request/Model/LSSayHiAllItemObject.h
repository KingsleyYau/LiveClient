//
//  LSSayHiAllItemObject.h
//  dating
//
//  Created by Alex on 19/4/18.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSayHiAllListItemObject.h"
/**
 * All列表
 * totalCount       总数
 * list             All列表
 */
@interface LSSayHiAllItemObject : NSObject
@property (nonatomic, assign) int totalCount;
@property (nonatomic, strong) NSMutableArray<LSSayHiAllListItemObject *>* list;

@end
