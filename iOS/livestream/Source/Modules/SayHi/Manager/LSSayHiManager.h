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
@property (nonatomic, copy) NSString *_Nullable themeId;
@property (nonatomic, copy) NSString *_Nullable bigImage;
// 记录上一次SayHi文本iId及文本内容
@property (nonatomic, assign) NSString *_Nullable textId;
@property (nonatomic, copy) NSString *_Nullable text;
@end

@interface LSSayHiManager : NSObject

/* 记录上一次操作SayHi配置(默认第一个配置) **/
@property (nonatomic, strong) LSLastSayHiConfigItem * _Nullable item;
/* 主题配置列表 **/
@property (nonatomic, strong) NSMutableArray * _Nullable sayHiThemeList;
/* 文本配置列表 **/
@property (nonatomic, strong) NSMutableArray * _Nullable sayHiTextList;

// 实例对象
+ (instancetype _Nullable)manager;

/** 获取SayHi配置列表 */
- (void)getSayHiConfig:(SayHiConfigFinishHandler _Nullable)finishHandler;

- (void)getFirstSayHiConfig;

- (void)removeAllSayHiConfig;

@end

