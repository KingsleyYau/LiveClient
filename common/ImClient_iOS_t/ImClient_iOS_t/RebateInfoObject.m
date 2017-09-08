//
//  RebateInfoObject.m
//  dating
//
//  Created by Alex on 17/8/15.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "RebateInfoObject.h"
@interface RebateInfoObject () <NSCoding>
@end


@implementation RebateInfoObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.curCredit = [coder decodeDoubleForKey:@"curCredit"];
        self.curTime = [coder decodeIntForKey:@"curTime"];
        self.preCredit = [coder decodeDoubleForKey:@"preCredit"];
        self.preTime = [coder decodeIntForKey:@"preTime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeDouble:self.curCredit forKey:@"curCredit"];
    [coder encodeInt:self.curTime forKey:@"curTime"];
    [coder encodeDouble:self.preCredit forKey:@"preCredit"];
    [coder encodeInt:self.preTime forKey:@"preTime"];
}

@end
