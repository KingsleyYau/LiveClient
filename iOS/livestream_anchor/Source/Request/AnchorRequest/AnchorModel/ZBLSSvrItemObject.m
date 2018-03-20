//
//  ZBLSSvrItemObject.m
//  dating
//
//  Created by Alex on 18/2/28.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "ZBLSSvrItemObject.h"
@interface ZBLSSvrItemObject () <NSCoding>
@end


@implementation ZBLSSvrItemObject

- (id)init {
    if( self = [super init] ) {
        self.svrId = @"";
        self.tUrl = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.svrId = [coder decodeObjectForKey:@"svrId"];
        self.tUrl = [coder decodeObjectForKey:@"tUrl"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.svrId forKey:@"svrId"];
    [coder encodeObject:self.tUrl forKey:@"tUrl"];
}

@end
