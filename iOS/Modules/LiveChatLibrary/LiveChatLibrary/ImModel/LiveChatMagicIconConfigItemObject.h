//
//  LiveChatMagicIconConfigItemObject.h
//  dating
//
//  Created by alex on 16/9/12.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MagicIconItemObject.h"
#import "MagicIconTypeItemObject.h"

@interface LiveChatMagicIconConfigItemObject : NSObject

/** 小高级表情路径 */
@property (nonatomic,strong) NSString *path;

/** 小高级表情配置最大更新时间 */
@property (nonatomic,assign) NSInteger maxupdatetime;
/** 小高级表情配置类型队列 */
@property (nonatomic,strong) NSArray<MagicIconTypeItemObject *> *typeList;
/** 小高级表情图队列 */
@property (nonatomic,strong) NSArray<MagicIconItemObject *> *magicIconList;


//初始化
- (LiveChatMagicIconConfigItemObject *)init;


@end
