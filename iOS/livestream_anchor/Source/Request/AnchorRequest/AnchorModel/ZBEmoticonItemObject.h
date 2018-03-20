//
//  ZBEmoticonItemObject.h
//  dating
//
//  Created by Alex on 18/2/28.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBEmoticonInfoItemObject.h"

@interface ZBEmoticonItemObject : NSObject
/**
 * 表情结构体
 * type   表情类型（ZBEMOTICONTYPE_STANDARD:Standard， ZBEMOTICONTYPE_ADVANCED:Advanced）
 * name      表情类型名称
 * errMsg    表情类型不可用的错误描述
 * emoUrl    表情类型icon url
 * emoList   表情信息队列
 */
@property (nonatomic, assign) ZBEmoticonType type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *errMsg;
@property (nonatomic, copy) NSString *emoUrl;
@property (nonatomic, strong) NSMutableArray<ZBEmoticonInfoItemObject *>* emoList;


@end
