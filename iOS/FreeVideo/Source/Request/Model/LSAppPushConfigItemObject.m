//
//  LSAppPushConfigItemObject.m
//  dating
//
//  Created by Alex on 17/9/12.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSAppPushConfigItemObject.h"
@interface LSAppPushConfigItemObject () <NSCoding>
@end


@implementation LSAppPushConfigItemObject

- (id)init {
    if( self = [super init] ) {
        self.isPriMsgAppPush = YES;
        self.isMailAppPush = YES;
        self.isSayHiAppPush = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.isPriMsgAppPush = [coder decodeBoolForKey:@"isPriMsgAppPush"];
        self.isMailAppPush = [coder decodeBoolForKey:@"isMailAppPush"];
        self.isSayHiAppPush = [coder decodeBoolForKey:@"isSayHiAppPush"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeBool:self.isPriMsgAppPush forKey:@"isPriMsgAppPush"];
    [coder encodeBool:self.isMailAppPush forKey:@"isMailAppPush"];
    [coder encodeBool:self.isSayHiAppPush forKey:@"isSayHiAppPush"];
}

@end
