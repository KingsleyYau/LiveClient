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
@property (nonatomic, strong) LSSessionRequestManager* sessionManager;
@property (nonatomic, strong) NSMutableArray* delegates;
@property (nonatomic, strong) ZBLSRequestManager *requestManager;
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
        self.sessionManager = [LSSessionRequestManager manager];
        self.requestManager= [ZBLSRequestManager manager];
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
- (void)getResevationsUnredCount
{
    ManBookingUnreadUnhandleNumRequest * request = [[ManBookingUnreadUnhandleNumRequest alloc]init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * errmsg, BookingUnreadUnhandleNumItemObject * item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @synchronized(self.delegates) {
                for(NSValue* value in self.delegates) {
                    id<LSUserUnreadCountManagerDelegate> delegate = value.nonretainedObjectValue;
                    if ([delegate respondsToSelector:@selector(onGetResevationsUnredCount:)]) {
                        [delegate onGetResevationsUnredCount:item];
                    }

                }
            }
        });
    };

    [self.sessionManager sendRequest:request];

}


- (void)getUnreadSheduledBooking {
    [self.requestManager anchorGetScheduledAcceptNum:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, int scheduledNum) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @synchronized(self.delegates) {
                for(NSValue* value in self.delegates) {
                    id<LSUserUnreadCountManagerDelegate> delegate = value.nonretainedObjectValue;
                    if ([delegate respondsToSelector:@selector(onGetUnreadSheduledBooking:)]) {
                        [delegate onGetUnreadSheduledBooking:scheduledNum];
                    }
                    
                }
            }
        });

    }];
}


@end
