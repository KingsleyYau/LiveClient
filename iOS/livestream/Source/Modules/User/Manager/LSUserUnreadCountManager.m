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

#pragma mark 请求我的背包未读数
- (void)getBackpackUnreadCount
{
    GetBackpackUnreadNumRequest * request = [[GetBackpackUnreadNumRequest alloc]init];
    
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, GetBackPackUnreadNumItemObject * _Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            @synchronized(self.delegates) {
                for(NSValue* value in self.delegates) {
                    id<LSUserUnreadCountManagerDelegate> delegate = value.nonretainedObjectValue;
                    if ([delegate respondsToSelector:@selector(onGetBackpackUnreadCount:)]) {
                        [delegate onGetBackpackUnreadCount:item];
                    }
                    
                }
            }
        });
    };
    
    [self.sessionManager sendRequest:request];
}

@end
