//
//  LiveAnalyticsManager.m
//  livestream
//
//  Created by Max on 2018/10/10.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LiveAnalyticsManager.h"

#import "LiveModule.h"
#import "LSLoginManager.h"
#import "LSGoogleAnalyticsAction.h"

@interface LiveAnalyticsManager () <LoginManagerDelegate>
@property (nonatomic, strong) LSLoginManager *loginManager;
@end

static LiveAnalyticsManager *liveAnalyticsManager = nil;

@implementation LiveAnalyticsManager
+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!liveAnalyticsManager) {
            liveAnalyticsManager = [[[self class] alloc] init];
        }
    });
    return liveAnalyticsManager;
}

- (id)init {
    if (self = [super init]) {
        self.loginManager = [LSLoginManager manager];
        [self.loginManager addDelegate:self];
    }
    return self;
}

- (void)dealloc {
    [self.loginManager removeDelegate:self];
}

#pragma mark - 登录成功处理
- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject *)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    [self reportUserId:loginItem.gaUid];
}

- (void)reportUserId:(NSString *)userId {
    // TODO:提交用户ID
    id<IAnalyticsManager> analyticsManager = [LiveModule module].analyticsManager;
    [analyticsManager reportActionEvent:LoginUserIdAction eventCategory:LoginUserIdCategory label:nil value:nil];
    [analyticsManager reportUserProperty:userId forkeyName:LoginUserIdCategory];
    [analyticsManager reportActionEvent:nil eventCategory:LoginUserIdCategory label:nil value:nil dimension:userId dimensionIndex:2];
}

@end
