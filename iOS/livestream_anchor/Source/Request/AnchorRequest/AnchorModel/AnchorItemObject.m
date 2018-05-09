//
//  AnchorItemObject.m
//  dating
//
//  Created by Alex on 18/4/3.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "AnchorItemObject.h"
@interface AnchorItemObject () <NSCoding>
@end


@implementation AnchorItemObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.age = [coder decodeIntForKey:@"age"];
        self.country = [coder decodeObjectForKey:@"country"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeInt:self.age forKey:@"age"];
    [coder encodeObject:self.country forKey:@"country"];

}

@end
