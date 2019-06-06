//
//  LSSayHiThemeItemObject.m
//  dating
//
//  Created by Alex on 19/4/18.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSayHiThemeItemObject.h"
@interface LSSayHiThemeItemObject () <NSCoding>
@end


@implementation LSSayHiThemeItemObject

- (id)init {
    if( self = [super init] ) {
        self.themeId = @"";
        self.themeName = @"";
        self.smallImg = @"";
        self.bigImg = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.themeId = [coder decodeObjectForKey:@"themeId"];
        self.themeName = [coder decodeObjectForKey:@"themeName"];
        self.smallImg = [coder decodeObjectForKey:@"smallImg"];
        self.bigImg = [coder decodeObjectForKey:@"bigImg"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.themeId forKey:@"themeId"];
    [coder encodeObject:self.themeName forKey:@"themeName"];
    [coder encodeObject:self.smallImg forKey:@"smallImg"];
    [coder encodeObject:self.bigImg forKey:@"bigImg"];

}

@end
