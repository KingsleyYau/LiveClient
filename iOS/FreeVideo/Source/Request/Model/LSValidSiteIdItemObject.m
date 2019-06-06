//
//  LSValidSiteIdItemObject.m
//  dating
//
//  Created by Alex on 18/9/20.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSValidSiteIdItemObject.h"
@interface LSValidSiteIdItemObject () <NSCoding>
@end


@implementation LSValidSiteIdItemObject

- (id)init {
    if( self = [super init] ) {
        self.siteId = HTTP_OTHER_SITE_UNKNOW;
        self.isLive = 0;

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.siteId = [coder decodeIntForKey:@"siteId"];
        self.isLive = [coder decodeBoolForKey:@"isLive"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.siteId forKey:@"siteId"];
    [coder encodeBool:self.isLive forKey:@"isLive"];

}

@end
