//
//  LiveNotificationService.m
//  livestream
//
//  Created by test on 2018/10/11.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LiveNotificationService.h"
#import "LiveModule.h"

#define liveSiteId @"41"
#define liveService @"live"
#define LiveAccept @"3"
static LiveNotificationService *gService = nil;
@implementation LiveNotificationService
+ (instancetype)service {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!gService) {
            gService = [[LiveNotificationService alloc] init];
        }
    });
    return gService;
}

- (id)init {
    NSLog(@"LiveNotificationService::init()");
    if (self = [super init]) {
    }
    return self;
}

- (void)parseNotificationUrl:(NSURL *)url {
    NSString *service = [LSURLQueryParam urlParamForKey:@"service" url:url];
    NSString *site = [LSURLQueryParam urlParamForKey:@"site" url:url];
    // 如果是直播模块才进行处理
    if ([service isEqualToString:liveService] || [site isEqualToString:liveSiteId]) {
        NSString *moduleString = [LSURLQueryParam urlParamForKey:@"module" url:url];
        if ([moduleString isEqualToString:@"chat"]) {
            [[LiveModule module].analyticsManager reportActionEvent:ClickPushNewMsg eventCategory:EventCategoryMessage];
        }else if ([moduleString isEqualToString:@"maillist"]) {
            [[LiveModule module].analyticsManager reportActionEvent:ClickPushNewMail eventCategory:EventCategoryMail];
        }else if ([moduleString isEqualToString:@"liveroom"]) {
            NSString *roomTypeString = [LSURLQueryParam urlParamForKey:@"roomtype" url:url];
            if ([roomTypeString isEqualToString:LiveAccept]) {
                [[LiveModule module].analyticsManager reportActionEvent:ClickInvitation eventCategory:EventCategoryGobal];
            }
        }else if ([moduleString isEqualToString:@"livechat"]) {
            [[LiveModule module].analyticsManager reportActionEvent:ClickLivechatPush eventCategory:EventCategoryLiveChat];
        }
    }
    
}

@end
