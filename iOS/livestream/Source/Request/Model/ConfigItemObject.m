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
        self.imSvrIp = @"";
        self.imSvrPort = 0;
        self.httpSvrIp = @"";
        self.httpSvrPort = 0;
        self.uploadSvrIp = @"";
        self.uploadSvrPort = 0;
        self.addCreditsUrl = @"";
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.imSvrIp = [coder decodeObjectForKey:@"imSvrIp"];
        self.imSvrPort = [coder decodeIntForKey:@"imSvrPort"];
        self.httpSvrIp = [coder decodeObjectForKey:@"httpSvrIp"];
        self.httpSvrPort = [coder decodeIntForKey:@"httpSvrPort"];
        self.uploadSvrIp = [coder decodeObjectForKey:@"uploadSvrIp"];
        self.uploadSvrPort = [coder decodeIntForKey:@"uploadSvrPort"];
        self.addCreditsUrl = [coder decodeObjectForKey:@"addCreditsUrl"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.imSvrIp forKey:@"imSvrIp"];
    [coder encodeInt:self.imSvrPort forKey:@"imSvrPort"];
    [coder encodeObject:self.httpSvrIp forKey:@"httpSvrIp"];
    [coder encodeInt:self.httpSvrPort forKey:@"httpSvrPort"];
    [coder encodeObject:self.uploadSvrIp forKey:@"uploadSvrIp"];
    [coder encodeInt:self.uploadSvrPort forKey:@"uploadSvrPort"];
    [coder encodeObject:self.addCreditsUrl forKey:@"addCreditsUrl"];

}

@end
