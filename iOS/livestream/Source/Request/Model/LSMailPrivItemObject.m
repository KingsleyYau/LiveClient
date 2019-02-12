//
//  LSMailPrivItemObject.m
//  dating
//
//  Created by Alex on 17/9/12.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSMailPrivItemObject.h"
@interface LSMailPrivItemObject () <NSCoding>
@end


@implementation LSMailPrivItemObject

- (id)init {
    if( self = [super init] ) {
        self.userSendMailPriv = true;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.userSendMailPriv = [coder decodeBoolForKey:@"userSendMailPriv"];
        self.userSendMailImgPriv = [coder decodeObjectForKey:@"userSendMailImgPriv"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeBool:self.userSendMailPriv forKey:@"userSendMailPriv"];
    [coder encodeObject:self.userSendMailImgPriv forKey:@"userSendMailImgPriv"];
}

@end
