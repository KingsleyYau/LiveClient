//
//  LSSayHiResourceConfigItemObject.h
//  dating
//
//  Created by Alex on 19/4/18.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSayHiTextItemObject.h"
#import "LSSayHiThemeItemObject.h"
/**
 * SayHi用到的主题和文本
 * themeList     主题列表
 * textList      文本列表
 */
@interface LSSayHiResourceConfigItemObject : NSObject
@property (nonatomic, strong) NSMutableArray<LSSayHiThemeItemObject *>* themeList;
@property (nonatomic, strong) NSMutableArray<LSSayHiTextItemObject *>* textList;

@end
