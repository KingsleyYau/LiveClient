//
//  LSLCLiveChatEmotionConfigItemObject.h
//  dating
//
//  Created by alex on 16/9/6.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSLCEmotionItemObject.h"
#import "LSLCEmotionTypeItemObject.h"
#import "LSLCEmotionTagItemObject.h"

@interface LSLCLiveChatEmotionConfigItemObject : NSObject

/** 高级表情版本号 */
@property (nonatomic,assign) NSInteger version;
/** 路径 */
@property (nonatomic,strong) NSString *path;
/** 高级表情类型队列 */
@property (nonatomic,strong) NSArray<LSLCEmotionTypeItemObject *> *typeList;
/** 高级表情Tag队列 */
@property (nonatomic,strong) NSArray<LSLCEmotionTagItemObject *> *tagList;
/** 男士的高级表情队列 */
@property (nonatomic,strong) NSArray<LSLCEmotionItemObject *> *manEmotionList;
/** 女士的高级表情队列 */
@property (nonatomic,strong) NSArray<LSLCEmotionItemObject *> *ladyEmotionList;


//初始化
- (LSLCLiveChatEmotionConfigItemObject *)init;


@end
