//
//  LSStreamSpeedManager.m
//  livestream
//
//  Created by randy on 2017/11/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSStreamSpeedManager.h"
#import "LSLoginManager.h"
#import "LSServerSpeedRequest.h"
#import "LSPushPullLogsRequest.h"
static LSStreamSpeedManager *manager = nil;
@interface LSStreamSpeedManager () <LoginManagerDelegate, NSURLSessionDelegate>

@property (nonatomic, strong) LSLoginManager *loginManager;
@property (strong, nonatomic) LSSessionRequestManager *sessionManager;

@property (nonatomic, strong) NSMutableArray *times;
@property (nonatomic, strong) NSMutableArray *svrIds;

@end

@implementation LSStreamSpeedManager
+ (instancetype)manager {
    if (manager == nil) {
        manager = [[[self class] alloc] init];
    }
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.loginManager = [LSLoginManager manager];
        [self.loginManager addDelegate:self];

        self.sessionManager = [LSSessionRequestManager manager];

        self.times = [[NSMutableArray alloc] init];
        self.svrIds = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject *)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    if (success) {
        [self.times removeAllObjects];
        [self.svrIds removeAllObjects];
        NSArray *svrList = loginItem.svrList;
        for (LSSvrItemObject *object in svrList) {
            NSLog(@"LSStreamSpeedManager::onLogin( [开始测速], svrId : %@, url : %@ )", object.svrId, object.tUrl);

            NSURLSession *session = [NSURLSession sharedSession];
            // 设置超时
            session.configuration.timeoutIntervalForRequest = 10;
            NSDate *startDate = [NSDate date];
            NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:object.tUrl]
                                                completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                                                    NSDate *date = [NSDate date];
                                                    NSTimeInterval time = [date timeIntervalSince1970] - [startDate timeIntervalSince1970];
                                                    int timeMS = error ? -1 : (time * 1000);
                                                    NSNumber *number = [NSNumber numberWithInt:timeMS];
                                                    [self.times addObject:number];
                                                    [self.svrIds addObject:object.svrId];
                                                    NSLog(@"LSStreamSpeedManager::onLogin( [测速], %@, svrId : %@, time : %dms, url : %@ )", BOOL2SUCCESS(!error), object.svrId, timeMS, object.tUrl);

                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        // 发送测速结果
                                                        [self requestSpeedResultWithLogin:object.svrId time:timeMS];
                                                    });
                                                }];
            [task resume];
        }
    }
}

- (void)requestSpeedResult:(NSString *)roomId {
    if (roomId.length > 0) {
        for (int index = 0; index < self.times.count; index++) {
            NSNumber *time = self.times[index];
            NSString *svrId = self.svrIds[index];
            LSServerSpeedRequest *request = [[LSServerSpeedRequest alloc] init];
            request.sid = svrId;
            request.res = time.intValue;
            request.liveRoomId = roomId;
            request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg) {
                NSLog(@"LSStreamSpeedManager::requestSpeedResultHandler( %@, errnum : %d, svrId : %@, time : %dms, roomId : %@ )", BOOL2SUCCESS(success), (int)errnum, svrId, time.intValue, roomId);
            };
            [self.sessionManager sendRequest:request];
        }
    }
}

- (void)requestSpeedResultWithLogin:(NSString *)svrId time:(int)time {
    if (svrId.length > 0) {
        LSServerSpeedRequest *request = [[LSServerSpeedRequest alloc] init];
        request.sid = svrId;
        request.res = time;
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg) {
            NSLog(@"LSStreamSpeedManager::requestSpeedResultWithLoginHandler( %@, errnum : %d, svrId : %@, time : %dms )", BOOL2SUCCESS(success), (int)errnum, svrId, time);
        };
        [self.sessionManager sendRequest:request];
    }
}

- (void)requestPushPullLogs:(NSString *)roomId {
    LSPushPullLogsRequest *request = [[LSPushPullLogsRequest alloc] init];
    request.liveRoomId = roomId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg) {
        NSLog(@"LSStreamSpeedManager::requestPushPullLogsHandler( %@, errnum : %d, errmsg : %@, roomId : %@ )", BOOL2SUCCESS(success), errnum, errmsg, roomId);
    };
    [self.sessionManager sendRequest:request];
}

@end
