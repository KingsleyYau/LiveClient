//
//  AnchorBaseInfoItemObject.m
//  dating
//
//  Created by Alex on 18/4/3.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "AnchorBaseInfoItemObject.h"
@interface AnchorBaseInfoItemObject () <NSCoding>
@end


@implementation AnchorBaseInfoItemObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];

}

@end
