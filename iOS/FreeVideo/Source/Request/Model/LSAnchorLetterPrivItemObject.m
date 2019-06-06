//
//  LSAnchorLetterPrivItemObject.m
//  dating
//
//  Created by Alex on 17/9/12.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSAnchorLetterPrivItemObject.h"
@interface LSAnchorLetterPrivItemObject () <NSCoding>
@end


@implementation LSAnchorLetterPrivItemObject

- (id)init {
    if( self = [super init] ) {
        self.userCanSend = true;
        self.anchorCanSend = true;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.userCanSend = [coder decodeBoolForKey:@"userCanSend"];
        self.anchorCanSend = [coder decodeBoolForKey:@"anchorCanSend"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeBool:self.userCanSend forKey:@"userCanSend"];
    [coder encodeBool:self.anchorCanSend forKey:@"anchorCanSend"];
}

@end
