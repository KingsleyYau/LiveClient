//
//  HotListAdManager.m
//  livestream
//
//  Created by test on 2019/10/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "HotListAdManager.h"

static HotListAdManager *gManager = nil;
@implementation HotListAdManager

+ (instancetype)manager {
    if (gManager == nil) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    if (self = [super init]) {
        self.sessionManager = [LSSessionRequestManager manager];
    }
    return self;
}

- (void)getHotListAD {
    LSWomanListAdvertRequest *request = [[LSWomanListAdvertRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSWomanListAdItemObject *item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"HotListAdManager::LSWomanListAdvertRequest( [获取女士列表随机广告], %@, advertId : %@ )", BOOL2SUCCESS(success), item.advertId);

            if ([self.hotAdDelegate respondsToSelector:@selector(hotListADLoad:Success:)]) {
                [self.hotAdDelegate hotListADLoad:item Success:success];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

@end
