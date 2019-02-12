//
//LMWarningItemObject.m
//  dating
//
//  Created by Alex on 18/6/25.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LMWarningItemObject.h"
@interface LMWarningItemObject () <NSCoding>
@end


@implementation LMWarningItemObject

- (id)init {
    if( self = [super init] ) {
        self.warnType = LMWarningType_Unknow;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.warnType = [coder decodeIntForKey:@"warnType"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.warnType forKey:@"warnType"];
}

@end
