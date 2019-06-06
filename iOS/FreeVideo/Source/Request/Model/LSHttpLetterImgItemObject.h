//
//  LSHttpLetterImgItemObject.h
//  dating
//
//  Created by Alex on 17/5/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

@interface LSHttpLetterImgItemObject : NSObject
{
}
/**
 * 图片详情(意向信没有收费参数：resourceId isFee status describe，都写死默认不付费，图片Id为空)
 * resourceId       图片Id
 * isFee            是否收费附件
 * status           付费状态（LSPAYFEESTATUS_UNPAID：未付费，LSPAYFEESTATUS_PAID：已付费，LSPAYFEESTATUS_OVERTIME：已过期）
 * describe         图片/视频描述
 * originImg        原图URL
 * smallImg         小图URL
 * blurImg          模糊图URL
 */
@property (nonatomic, copy) NSString* _Nonnull resourceId;
@property (nonatomic, assign) BOOL isFee;
@property (nonatomic, assign) LSPayFeeStatus status;
@property (nonatomic, copy) NSString* _Nonnull describe;
@property (nonatomic, copy) NSString* _Nonnull originImg;
@property (nonatomic, copy) NSString* _Nonnull smallImg;
@property (nonatomic, copy) NSString* _Nonnull blurImg;

@end
