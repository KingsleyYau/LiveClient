//
//  AnchorHangoutItemObject.m
//  dating
//
//  Created by Alex on 18/4/3.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "AnchorHangoutItemObject.h"
@interface AnchorHangoutItemObject () <NSCoding>
@end


@implementation AnchorHangoutItemObject

- (id)init {
    if( self = [super init] ) {
        self.userId = @"";
        self.nickName = @"";
        self.photoUrl = @"";
        self.roomId = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.userId = [coder decodeObjectForKey:@"userId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.anchorList = [coder decodeObjectForKey:@"anchorList"];
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeObject:self.anchorList forKey:@"anchorList"];
    [coder encodeObject:self.roomId forKey:@"roomId"];

}

@end
