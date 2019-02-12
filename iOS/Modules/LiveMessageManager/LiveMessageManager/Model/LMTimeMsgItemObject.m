//
//LMTimeMsgItemObject.m
//  dating
//
//  Created by Alex on 18/6/25.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LMTimeMsgItemObject.h"
@interface LMTimeMsgItemObject () <NSCoding>
@end


@implementation LMTimeMsgItemObject

- (id)init {
    if( self = [super init] ) {
        self.msgTime = 0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.msgTime = [coder decodeIntegerForKey:@"msgTime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.msgTime forKey:@"msgTime"];
}

@end
