//
//  EmoticonInfoItemObject.h
//  dating
//
//  Created by Alex on 17/8/17.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

@interface EmoticonInfoItemObject : NSObject
/* 表情ID */
@property (nonatomic, copy) NSString* emoId;
/* 表情文本标记 */
@property (nonatomic, copy) NSString* emoSign;
/* 表情图片url */
@property (nonatomic, copy) NSString* emoUrl;

@end
