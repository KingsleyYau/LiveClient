//
//  LSRecipientAnchorItemObject.m
//  dating
//
//  Created by Alex on 19/9/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSRecipientAnchorItemObject.h"
@interface LSRecipientAnchorItemObject () <NSCoding>
@end


@implementation LSRecipientAnchorItemObject
- (id)init {
    if( self = [super init] ) {
        self.anchorId = @"";
        self.anchorNickName = @"";
        self.anchorAvatarImg = @"";
        self.anchorAge = 0;
    }
 return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.anchorNickName = [coder decodeObjectForKey:@"anchorNickName"];
        self.anchorAvatarImg = [coder decodeObjectForKey:@"anchorAvatarImg"];
        self.anchorAge = [coder decodeIntForKey:@"anchorAge"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.anchorNickName forKey:@"anchorNickName"];
    [coder encodeObject:self.anchorAvatarImg forKey:@"anchorAvatarImg"];
    [coder encodeInt:self.anchorAge forKey:@"anchorAge"];
}

@end
