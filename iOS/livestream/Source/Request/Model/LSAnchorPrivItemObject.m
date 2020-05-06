//
//  LSAnchorPrivItemObject.m
//  dating
//
//  Created by Alex on 20/04/10.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSAnchorPrivItemObject.h"
@interface LSAnchorPrivItemObject () <NSCoding>
@end


@implementation LSAnchorPrivItemObject

- (id)init {
    if( self = [super init] ) {
        self.scheduleOneOnOneRecvPriv = NO;
        self.scheduleOneOnOneSendPriv = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.scheduleOneOnOneRecvPriv = [coder decodeBoolForKey:@"scheduleOneOnOneRecvPriv"];
        self.scheduleOneOnOneSendPriv = [coder decodeBoolForKey:@"scheduleOneOnOneSendPriv"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeBool:self.scheduleOneOnOneRecvPriv forKey:@"scheduleOneOnOneRecvPriv"];
    [coder encodeBool:self.scheduleOneOnOneSendPriv forKey:@"scheduleOneOnOneSendPriv"];
}

@end
