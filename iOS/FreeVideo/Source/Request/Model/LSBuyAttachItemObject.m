//
//  LSBuyAttachItemObject.m
//  dating
//
//  Created by Alex on 17/5/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSBuyAttachItemObject.h"
@interface LSBuyAttachItemObject () <NSCoding>
@end


@implementation LSBuyAttachItemObject
- (id)init {
    if( self = [super init] ) {
        self.emfId = @"";
        self.resourceId = @"";
        self.originImg = @"";
        self.videoUrl = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.emfId = [coder decodeObjectForKey:@"emfId"];
        self.resourceId = [coder decodeObjectForKey:@"resourceId"];
        self.originImg = [coder decodeObjectForKey:@"originImg"];
        self.videoUrl = [coder decodeObjectForKey:@"videoUrl"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.emfId forKey:@"emfId"];
    [coder encodeObject:self.resourceId forKey:@"resourceId"];
    [coder encodeObject:self.originImg forKey:@"originImg"];
    [coder encodeObject:self.videoUrl forKey:@"videoUrl"];
}

@end
