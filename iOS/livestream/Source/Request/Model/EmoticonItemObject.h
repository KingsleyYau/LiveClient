//
//  EmoticonItemObject.h
//  dating
//
//  Created by Alex on 17/8/17.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EmoticonInfoItemObject.h"
#import <httpcontroller/HttpRequestEnum.h>

@interface EmoticonItemObject : NSObject
/**
 * 表情结构体
 * type      表情类型（0:Standard， 1:Advanced）
 * name      表情类型名称
 * errMsg    表情类型不可用的错误描述
 * emoUrl    表情类型icon url
 * emoList   表情信息队列
 */
@property (nonatomic, assign) EmoticonType type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *errMsg;
@property (nonatomic, copy) NSString *emoUrl;
@property (nonatomic, strong) NSMutableArray<EmoticonInfoItemObject *>* emoList;


@end
