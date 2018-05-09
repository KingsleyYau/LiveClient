//
// LSHangoutAnchorItemObject.h
//  dating
//
//  Created by Alex on 18/4/12.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface LSHangoutAnchorItemObject : NSObject
/**
 * 多人互动的主播列表结构体
 * anchorId         主播ID
 * nickName         昵称
 * photoUrl         头像
 * age              年龄
 * country            国家
 */
@property (nonatomic, copy) NSString* _Nonnull anchorId;
@property (nonatomic, copy) NSString* _Nonnull nickName;
@property (nonatomic, copy) NSString* _Nonnull photoUrl;
@property (nonatomic, assign) int age;
@property (nonatomic, copy) NSString* _Nonnull country;


@end
