//
//  WomanListAdItemObject.h
//  dating
//
//  Created by test on 2018/7/04.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

@interface LSWomanListAdItemObject : NSObject
/** 广告 */
@property (nonatomic, copy) NSString *advertId;
/** 图片URL */
@property (nonatomic, copy) NSString *image;
/** 图片宽度 */
@property (nonatomic, assign) int width;
/** 图片高度 */
@property (nonatomic, assign) int height;
/** 点击打开的URL */
@property (nonatomic, copy) NSString *adurl;
/** URL打开方式 */
@property (nonatomic, assign) LSAdvertOpenType openType;
/** 广告标题 */
@property (nonatomic, copy) NSString *advertTitle;

@property (nonatomic, assign) LSAdvertSpaceType type;//广告位类型
@end

