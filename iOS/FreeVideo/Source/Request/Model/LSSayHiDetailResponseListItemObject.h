//
//  LSSayHiDetailResponseListItemObject.h
//  dating
//
//  Created by Alex on 19/4/18.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * sayHi回复列表
 * responseId           回复ID
 * responseTime         回复时间戳
 * simpleContent        回复内容的摘要
 * content              回复内容
 * isFree               是否免费（YES：是，NO：否）
 * hasRead              是否已读（YES：是，NO：否）
 * hasImg               是否有图片（YES：有，NO：无）
 * img                  图片地址
 * isUnfold             是否展开，用于列表UI
 * imageH               图片高度
 * contentH             内容高度
 */

typedef enum {
    SayHiDetailLoadingType_None,
    SayHiDetailLoadingType_Successed,
    SayHiDetailLoadingType_NoData,
    SayHiDetailLoadingType_Fail,
    SayHiDetailLoadingType_NoCredits
}SayHiDetailLoadingType;

@interface LSSayHiDetailResponseListItemObject : NSObject
@property (nonatomic, copy) NSString *responseId;
@property (nonatomic, assign) NSInteger responseTime;
@property (nonatomic, copy) NSString *simpleContent;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) BOOL isFree;
@property (nonatomic, assign) BOOL hasRead;
@property (nonatomic, assign) BOOL hasImg;
@property (nonatomic, copy) NSString *img;
@property (nonatomic, assign) BOOL isUnfold;
@property (nonatomic, assign) CGFloat imageH;
@property (nonatomic, assign) CGFloat contentH;
@property (nonatomic, assign) SayHiDetailLoadingType type;
@end
