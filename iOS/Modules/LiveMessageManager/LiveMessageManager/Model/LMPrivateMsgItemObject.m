//
//LMPrivateMsgItemObject.m
//  dating
//
//  Created by Alex on 18/6/25.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LMPrivateMsgItemObject.h"
@interface LMPrivateMsgItemObject () <NSCoding>
@end


@implementation LMPrivateMsgItemObject

- (id)init {
    if( self = [super init] ) {
        self.message = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.message = [coder decodeObjectForKey:@"message"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {

    [coder encodeObject:self.message forKey:@"message"];
}

@end
