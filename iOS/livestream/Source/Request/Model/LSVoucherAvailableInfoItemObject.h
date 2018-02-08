//
//  LSVoucherAvailableInfoItemObject.h
//  dating
//
//  Created by Alex on 18/1/24.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSBindAnchorItemObject.h"
@interface LSVoucherAvailableInfoItemObject : NSObject
/**
 * 使用卷结构体
 * onlypublicExpTime        仅公开直播（且不限制主播且不限制新关系）试用券到期时间（1970年起的秒数）
 * onlyprivateExpTime       仅私密直播（且不限制主播且不限制新关系）试用券到期时间（1970年起的秒数）
 * bindAnchor               绑定主播列表
 * onlypublicNewExpTime     仅公开的新关系试用券到期时间（1970年起的秒数）
 * onlyprivateNewExpTime    仅私密的新关系试用券到期时间（1970年起的秒数）
 * watchedAnchor            我看过的主播列表
 */

@property (nonatomic, assign) NSInteger onlypublicExpTime;
@property (nonatomic, assign) NSInteger onlyprivateExpTime;
@property (nonatomic, strong) NSMutableArray<LSBindAnchorItemObject *>* _Nonnull bindAnchor;
@property (nonatomic, assign) NSInteger onlypublicNewExpTime;
@property (nonatomic, assign) NSInteger onlyprivateNewExpTime;
@property (nonatomic, strong) NSMutableArray<NSString *>* _Nonnull watchedAnchor;

@end
