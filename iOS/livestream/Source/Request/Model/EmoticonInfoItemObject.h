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
/* 表情类型（EMOTICONACTIONTYPE_STATIC：静态表情，EMOTICONACTIONTYPE_DYNAMIC：动画表情） */
@property (nonatomic, assign) EmoticonActionType emoType;
/* 表情icon图片url，用于移动端在表情列表显示
 */
@property (nonatomic, copy) NSString* emoIconUrl;

@end
