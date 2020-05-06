//
//  LSScheduleinviteStatusItemObject.m
//  dating
//
//  Created by Alex on 20/03/30.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSScheduleinviteStatusItemObject.h"
@interface LSScheduleinviteStatusItemObject () <NSCoding>
@end


@implementation LSScheduleinviteStatusItemObject
- (id)init {
    if( self = [super init] ) {
        self.needStartNum = 0;
        self.beStartNum = 0;
        self.beStrtTime = 0;
        self.startLeftSeconds = 0;

    }
 return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.needStartNum = [coder decodeIntForKey:@"needStartNum"];
        self.beStartNum = [coder decodeIntForKey:@"beStartNum"];
        self.beStrtTime = [coder decodeIntegerForKey:@"beStrtTime"];
        self.startLeftSeconds = [coder decodeIntForKey:@"startLeftSeconds"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.needStartNum forKey:@"needStartNum"];
    [coder encodeInt:self.beStartNum forKey:@"beStartNum"];
    [coder encodeInteger:self.beStrtTime forKey:@"beStrtTime"];
    [coder encodeInt:self.startLeftSeconds forKey:@"startLeftSeconds"];

}

@end
