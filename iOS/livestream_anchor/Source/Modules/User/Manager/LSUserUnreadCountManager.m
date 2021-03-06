//
//  LSUserUnreadCountManager.m
//  livestream
//
//  Created by Calvin on 17/10/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSUserUnreadCountManager.h"

static LSUserUnreadCountManager * unreadCountinstance;

@interface LSUserUnreadCountManager ()
@property (nonatomic, strong) NSMutableArray* delegates;
@property (nonatomic, strong) LSAnchorRequestManager *requestManager;
@end

@implementation LSUserUnreadCountManager

+(instancetype _Nonnull)shareInstance{
    @synchronized (self) {
        if (unreadCountinstance == nil) {
            unreadCountinstance = [[LSUserUnreadCountManager alloc] init];
        }
        return unreadCountinstance;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestManager = [LSAnchorRequestManager manager];
        self.delegates = [NSMutableArray array];
     }
    return self;
}

- (void)addDelegate:(id<LSUserUnreadCountManagerDelegate>)delegate {
    @synchronized(self.delegates) {
        [self.delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
    }
}

- (void)removeDelegate:(id<LSUserUnreadCountManagerDelegate>)delegate {
    @synchronized(self.delegates) {
        for(NSValue* value in self.delegates) {
            id<LSUserUnreadCountManagerDelegate> item = (id<LSUserUnreadCountManagerDelegate>)value.nonretainedObjectValue;
            if( item == delegate ) {
                [self.delegates removeObject:value];
                break;
            }
        }
    }
}


#pragma mark 请求预约未读数

- (void)getUnreadSheduledBooking {
    [self.requestManager anchorGetScheduleListNoReadNum:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, ZBBookingUnreadUnhandleNumItemObject * _Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @synchronized(self.delegates) {
                for(NSValue* value in self.delegates) {
                    id<LSUserUnreadCountManagerDelegate> delegate = value.nonretainedObjectValue;
                    if ([delegate respondsToSelector:@selector(onGetUnreadSheduledBooking:)]) {
                        [delegate onGetUnreadSheduledBooking:item.scheduledNoReadNum];
                    }
                }
            }
        });

    }];
}

- (void)getUnreadShowCalendar {
    [self.requestManager anchorGetNoReadNumProgram:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, int num) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSMainViewController::anchorGetNoReadNumProgram( [节目未读信息], success : %d, errmsg :%@, num : %d )", success, errmsg, num);
            @synchronized(self.delegates) {
                for(NSValue* value in self.delegates) {
                    id<LSUserUnreadCountManagerDelegate> delegate = value.nonretainedObjectValue;
                    if ([delegate respondsToSelector:@selector(onGetUnreadShowCalendar:)]) {
                        [delegate onGetUnreadShowCalendar:num];
                    }
                }
            }
        });
    }];
}
@end
