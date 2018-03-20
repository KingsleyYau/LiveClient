//
//  ZBEmoticonInfoItemObject.h
//  dating
//
//  Created by Alex on 18/2/28.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <anchorhttpcontroller/ZBHttpRequestEnum.h>

@interface ZBEmoticonInfoItemObject : NSObject
/* 表情ID */
@property (nonatomic, copy) NSString* emoId;
/* 表情文本标记 */
@property (nonatomic, copy) NSString* emoSign;
/* 表情图片url */
@property (nonatomic, copy) NSString* emoUrl;
/* 表情类型（ZBEMOTICONACTIONTYPE_STATIC：静态表情，ZBEMOTICONACTIONTYPE_DYNAMIC1：动画表情） */
@property (nonatomic, assign)ZBEmoticonActionType emoType;
/* 表情icon图片url，用于移动端在表情列表显示
 */
@property (nonatomic, copy) NSString* emoIconUrl;

@end
