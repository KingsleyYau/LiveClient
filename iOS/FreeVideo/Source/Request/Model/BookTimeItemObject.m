//
//  BookTimeItemObject.m
//  dating
//
//  Created by Alex on 17/8/30.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "BookTimeItemObject.h"
@interface BookTimeItemObject () <NSCoding>
@end


@implementation BookTimeItemObject

- (id)init {
    if( self = [super init] ) {
        self.timeId = @"";
        self.time = 0;
        self.status = 0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.timeId = [coder decodeObjectForKey:@"timeId"];
        self.time = [coder decodeIntegerForKey:@"time"];
        self.status = [coder decodeIntForKey:@"status"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.timeId forKey:@"timeId"];
    [coder encodeInteger:self.time forKey:@"time"];
    [coder encodeInt:self.status forKey:@"status"];

}

@end
