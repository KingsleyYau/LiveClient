//
//  LiveChatEmotionConfigItemObject.h
//  dating
//
//  Created by alex on 16/9/6.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EmotionItemObject.h"
#import "EmotionTypeItemObject.h"
#import "EmotionTagItemObject.h"

@interface LiveChatEmotionConfigItemObject : NSObject

/** 高级表情版本号 */
@property (nonatomic,assign) NSInteger version;
/** 路径 */
@property (nonatomic,strong) NSString *path;
/** 高级表情类型队列 */
@property (nonatomic,strong) NSArray<EmotionTypeItemObject *> *typeList;
/** 高级表情Tag队列 */
@property (nonatomic,strong) NSArray<EmotionTagItemObject *> *tagList;
/** 男士的高级表情队列 */
@property (nonatomic,strong) NSArray<EmotionItemObject *> *manEmotionList;
/** 女士的高级表情队列 */
@property (nonatomic,strong) NSArray<EmotionItemObject *> *ladyEmotionList;


//初始化
- (LiveChatEmotionConfigItemObject *)init;


@end
