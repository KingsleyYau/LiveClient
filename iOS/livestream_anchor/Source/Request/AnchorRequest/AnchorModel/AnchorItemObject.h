//
//  AnchorItemObject.h
//  dating
//
//  Created by Alex on 18/4/3.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnchorItemObject : NSObject
/**
 * 主播列表
 * 主播列表结构体
 * anchorId             主播ID
 * nickName             昵称
 * photoUrl             头像url
 * age                  年龄
 * country              国家
 */
@property (nonatomic, copy) NSString* anchorId;
@property (nonatomic, copy) NSString* nickName;
@property (nonatomic, copy) NSString* photoUrl;
@property (nonatomic, assign) int age;
@property (nonatomic, copy) NSString* country;
@end
