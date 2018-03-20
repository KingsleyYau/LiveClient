//
//  LSOrderProductItemObject.m
//  dating
//
//  Created by Alex on 17/12/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSOrderProductItemObject.h"
@interface LSOrderProductItemObject () <NSCoding>
@end


@implementation LSOrderProductItemObject

- (id)init {
    if( self = [super init] ) {
        self.desc = @"";
        self.more = @"";

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.list = [coder decodeObjectForKey:@"list"];
        self.desc = [coder decodeObjectForKey:@"desc"];
        self.more = [coder decodeObjectForKey:@"more"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.list forKey:@"list"];
    [coder encodeObject:self.desc forKey:@"desc"];
    [coder encodeObject:self.more forKey:@"more"];
}

@end
