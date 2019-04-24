//
//  LSSayHiManager.h
//  livestream
//
//  Created by Randy_Fan on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSSayHiConfigRequest.h"

@interface LSLastSayHiConfigItem : NSObject
// 记录上一次发送SayHi主题Id及背景url
@property (nonatomic, assign) int themeId;
@property (nonatomic, copy) NSString *_Nullable bigImage;
// 记录上一次SayHi文本iId及文本内容
@property (nonatomic, assign) int textId;
@property (nonatomic, copy) NSString *_Nullable text;
@end

@interface LSSayHiManager : NSObject

// 记录上一次操作SayHi配置
@property (nonatomic, strong) LSLastSayHiConfigItem * _Nullable item;

// 实例对象
+ (instancetype _Nullable)manager;

/** 获取SayHi配置列表 */
- (void)getSayHiConfig:(SayHiConfigFinishHandler _Nullable)finishHandler;

/** 记录SayHi配置 */
- (void)setLastSayHiConfigItem:(int)themeId bigImg:(NSString *_Nullable)bigImg textId:(int)textId text:(NSString *_Nullable)text;


@end

