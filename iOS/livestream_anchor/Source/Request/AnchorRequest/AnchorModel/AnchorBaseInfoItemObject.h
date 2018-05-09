//
//  AnchorBaseInfoItemObject
//  dating
//
//  Created by Alex on 18/4/3.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnchorBaseInfoItemObject : NSObject
/**
 * 主播列表
 * 主播列表结构体
 * anchorId             主播ID
 * nickName             昵称
 * photoUrl             头像url
 */
@property (nonatomic, copy) NSString* anchorId;
@property (nonatomic, copy) NSString* nickName;
@property (nonatomic, copy) NSString* photoUrl;
@end
