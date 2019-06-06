//
//  LSOrderProductItemObject.m
//  dating
//
//  Created by Alex on 18/9/21.
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
        self.title = @"";
        self.subTitle = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.list = [coder decodeObjectForKey:@"list"];
        self.desc = [coder decodeObjectForKey:@"desc"];
        self.more = [coder decodeObjectForKey:@"more"];
        self.title = [coder decodeObjectForKey:@"title"];
        self.subTitle = [coder decodeObjectForKey:@"subTitle"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.list forKey:@"list"];
    [coder encodeObject:self.desc forKey:@"desc"];
    [coder encodeObject:self.more forKey:@"more"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.subTitle forKey:@"subTitle"];
}

@end
