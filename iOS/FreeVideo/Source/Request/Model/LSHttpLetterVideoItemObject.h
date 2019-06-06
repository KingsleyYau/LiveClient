//
//  LSHttpLetterVideoItemObject.h
//  dating
//
//  Created by Alex on 17/5/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

@interface LSHttpLetterVideoItemObject : NSObject
{
    
}
/**
 * 信件视频(意向信没有收费参数：resourceId isFee status describe，都写死默认不付费，图片Id为空， 意向信只有视频封面图URL，这里coverSmallImg，coverOriginImg意向信就给同一个值)
 * resourceId       图片/视频ID
 * isFee            是否收费附件
 * status           付费状态
 * describe         图片/视频描述
 * payItem          支付item
 * coverSmallImg    视频封面小图URL
 * coverOriginImg   视频封面原图URL
 * video            视频URL
 * videoTotalTime    视频总时长（秒）
 */
@property (nonatomic, copy) NSString* _Nonnull resourceId;
@property (nonatomic, assign) BOOL isFee;
@property (nonatomic, assign) LSPayFeeStatus status;
@property (nonatomic, copy) NSString* _Nonnull describe;
@property (nonatomic, copy) NSString* _Nonnull coverSmallImg;
@property (nonatomic, copy) NSString* _Nonnull coverOriginImg;
@property (nonatomic, copy) NSString* _Nonnull video;
@property (nonatomic, assign) double videoTotalTime;


@end

