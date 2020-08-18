//
//  LSPremiumVideoRecentlyWatchedItemObject.m
//  dating
//
//  Created by Alex on 20/08/05.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSPremiumVideoRecentlyWatchedItemObject.h"
@interface LSPremiumVideoRecentlyWatchedItemObject () <NSCoding>
@end


@implementation LSPremiumVideoRecentlyWatchedItemObject

- (id)init {
    if( self = [super init] ) {
        self.watchedId = @"";
        self.premiumVideoInfo = NULL;
        self.addTime = 0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.watchedId = [coder decodeObjectForKey:@"watchedId"];
        self.premiumVideoInfo = [coder decodeObjectForKey:@"premiumVideoInfo"];
        self.addTime = [coder decodeIntegerForKey:@"addTime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.watchedId forKey:@"watchedId"];
    [coder encodeObject:self.premiumVideoInfo forKey:@"premiumVideoInfo"];
    [coder encodeInteger:self.addTime forKey:@"addTime"];
}

@end
