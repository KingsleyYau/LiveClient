//
//  LSSayHiResponseItemObject.h
//  dating
//
//  Created by Alex on 19/4/18.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSayHiResponseListItemObject.h"
/**
 * Waiting for your reply列表
 * totalCount       总数
 * list             All列表
 */
@interface LSSayHiResponseItemObject : NSObject
@property (nonatomic, assign) int totalCount;
@property (nonatomic, strong) NSMutableArray<LSSayHiResponseListItemObject *>* list;

@end
