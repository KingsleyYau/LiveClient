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
        self.sessionManager = [LSSessionRequestManager manager];
        
        [self getSayHiConfig:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSSayHiResourceConfigItemObject *item) {
            NSLog(@"LSSayHiManager::init([获取SayHi默认配置])");
            if (success) {
                LSSayHiThemeItemObject *themeObj = item.themeList.firstObject;
                LSSayHiTextItemObject *textObj = item.textList.firstObject;
                // 初始化默认SayHi配置
                [self setLastSayHiConfigItem:themeObj.themeId bigImg:themeObj.bigImg textId:textObj.textId text:textObj.text];
            }
        }];
    }
    return self;
}

- (void)getSayHiConfig:(SayHiConfigFinishHandler _Nullable)finishHandler {
    LSSayHiConfigRequest *request = [[LSSayHiConfigRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSSayHiResourceConfigItemObject *item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSSayHiManager::LSSayHiConfigRequest([获取SayHi配置信息] success : %@, errnum : %d, errmsg : %@, themeList : %lu, textList : %lu )",BOOL2SUCCESS(success), errnum, errmsg, (unsigned long)item.themeList.count, (unsigned long)item.textList.count);
            
            finishHandler(success, errnum, errmsg, item);
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)setLastSayHiConfigItem:(int)themeId bigImg:(NSString *_Nullable)bigImg textId:(int)textId text:(NSString *_Nullable)text {
    if (!self.item) {
        self.item = [[LSLastSayHiConfigItem alloc] init];
    }
    self.item.themeId = themeId;
    self.item.bigImage = bigImg;
    self.item.textId = textId;
    self.item.text = text;
}

@end
