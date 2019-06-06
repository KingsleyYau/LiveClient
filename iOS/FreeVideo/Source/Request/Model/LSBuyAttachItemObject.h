//
//  LSBuyAttachItemObject.h
//  dating
//
//  Created by Alex on 17/5/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSBuyAttachItemObject : NSObject
{
}
/**
 * 购买信件附件
 * emfId             信件ID
 * resourceId        附件ID
 * originImg         图片原图URL或视频封面图URL
 * videoUrl          视频URL（可无，仅视频附件时存在）
 */
@property (nonatomic, copy) NSString* _Nonnull emfId;
@property (nonatomic, copy) NSString* _Nonnull resourceId;
@property (nonatomic, copy) NSString* _Nonnull originImg;
@property (nonatomic, copy) NSString* _Nonnull videoUrl;

@end
