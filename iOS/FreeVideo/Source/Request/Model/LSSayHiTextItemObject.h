//
//  LSSayHiTextItemObject.h
//  dating
//
//  Created by Alex on 19/4/18.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * 文本列表
 * textId     文本ID
 * text       文本内容
 */
@interface LSSayHiTextItemObject : NSObject
@property (nonatomic, copy) NSString *textId;
@property (nonatomic, copy) NSString *text;

@end
