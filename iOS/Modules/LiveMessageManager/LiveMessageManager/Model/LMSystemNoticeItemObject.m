//
//LMSystemNoticeItemObject.m
//  dating
//
//  Created by Alex on 18/6/25.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LMSystemNoticeItemObject.h"
@interface LMSystemNoticeItemObject () <NSCoding>
@end


@implementation LMSystemNoticeItemObject

- (id)init {
    if( self = [super init] ) {
        self.message = @"";
        self.systemType = LMSystemType_Unknow;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.message = [coder decodeObjectForKey:@"message"];
        self.systemType = [coder decodeIntForKey:@"systemType"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {

    [coder encodeObject:self.message forKey:@"message"];
    [coder encodeInt:self.systemType forKey:@"systemType"];
}

@end
