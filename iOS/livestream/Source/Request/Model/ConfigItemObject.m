//
//  ConfigItemObject.m
//  dating
//
//  Created by Alex on 17/8/17.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "ConfigItemObject.h"
@interface ConfigItemObject () <NSCoding>
@end


@implementation ConfigItemObject

- (id)init {
    if( self = [super init] ) {
        self.imSvrUrl = @"";
        self.httpSvrUrl = @"";
        self.addCreditsUrl = @"";
        self.anchorPage = @"";
        self.userLevel = @"";
        self.intimacy = @"";
        self.userProtocol = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.imSvrUrl = [coder decodeObjectForKey:@"imSvrUrl"];
        self.httpSvrUrl = [coder decodeObjectForKey:@"httpSvrUrl"];
        self.addCreditsUrl = [coder decodeObjectForKey:@"addCreditsUrl"];
        self.anchorPage = [coder decodeObjectForKey:@"anchorPage"];
        self.userLevel = [coder decodeObjectForKey:@"userLevel"];
        self.intimacy = [coder decodeObjectForKey:@"intimacy"];
        self.userProtocol = [coder decodeObjectForKey:@"userProtocol"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.imSvrUrl forKey:@"imSvrUrl"];
    [coder encodeObject:self.httpSvrUrl forKey:@"httpSvrUrl"];
    [coder encodeObject:self.addCreditsUrl forKey:@"addCreditsUrl"];
    [coder encodeObject:self.anchorPage forKey:@"anchorPage"];
    [coder encodeObject:self.userLevel forKey:@"userLevel"];
    [coder encodeObject:self.intimacy forKey:@"intimacy"];
    [coder encodeObject:self.userProtocol forKey:@"userProtocol"];

}

@end
