//
//  LSSayHiManager.m
//  livestream
//
//  Created by Randy_Fan on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiManager.h"

#import "LSSessionRequestManager.h"

@implementation LSLastSayHiConfigItem

@end

@interface LSSayHiManager()

@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

@end

static LSSayHiManager *manager = nil;
@implementation LSSayHiManager

+ (instancetype)manager {
    if (!manager) {
        manager = [[LSSayHiManager alloc] init];
    }
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sayHiThemeList = [[NSMutableArray alloc] init];
        self.sayHiTextList = [[NSMutableArray alloc] init];
        
        self.sessionManager = [LSSessionRequestManager manager];
    }
    return self;
}

- (void)getSayHiConfig:(SayHiConfigFinishHandler _Nullable)finishHandler {
    LSSayHiConfigRequest *request = [[LSSayHiConfigRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSSayHiResourceConfigItemObject *item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSSayHiManager::LSSayHiConfigRequest([获取SayHi默认配置] success : %@, errnum : %d, errmsg : %@, themeList : %lu, textList : %lu )",BOOL2SUCCESS(success), errnum, errmsg, (unsigned long)item.themeList.count, (unsigned long)item.textList.count);
            
            finishHandler(success, errnum, errmsg, item);
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)getFirstSayHiConfig {
    // 获取sayhi配置
    WeakObject(self, weakSelf);
    [self getSayHiConfig:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSSayHiResourceConfigItemObject *item) {
        if (success) {
            
            if (item.textList.count > 0) {
                // 无用户配置则创建
                if (!weakSelf.item) {
                    weakSelf.item = [[LSLastSayHiConfigItem alloc] init];
                }
                // 记录文本配置列表
                weakSelf.sayHiTextList = item.textList;
                // HTTP重登陆是否需要替换用户文本操作配置
                BOOL haveText = NO;
                for (LSSayHiTextItemObject *obj in item.textList) {
                    if ([weakSelf.item.textId isEqualToString:obj.textId]) {
                        haveText = YES;
                    }
                }
                if (!haveText) {
                    LSSayHiTextItemObject *textObj = item.textList.firstObject;
                    weakSelf.item.textId = textObj.textId;
                    weakSelf.item.text = textObj.text;
                }
            }
            
            if (item.themeList.count > 0) {
                if (!weakSelf.item) {
                    weakSelf.item = [[LSLastSayHiConfigItem alloc] init];
                }
                // 记录主题配置列表
                weakSelf.sayHiThemeList = item.themeList;
                // HTTP重登陆是否需要替换用户主题操作配置
                BOOL haveTheme = NO;
                for (LSSayHiThemeItemObject *obj in item.themeList) {
                    if ([weakSelf.item.themeId isEqualToString:obj.themeId]) {
                        haveTheme = YES;
                    }
                }
                if (!haveTheme) {
                    LSSayHiThemeItemObject *themeObj = item.themeList.firstObject;
                    weakSelf.item.themeId = themeObj.themeId;
                    weakSelf.item.bigImage = themeObj.bigImg;
                }
            }
        }
    }];
}

- (void)removeAllSayHiConfig {
    [self.sayHiTextList removeAllObjects];
    [self.sayHiThemeList removeAllObjects];
    self.item = nil;
}

@end
