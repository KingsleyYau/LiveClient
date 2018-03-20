//
//  ZBConfigItemObject.m
//  dating
//
//  Created by Alex on 18/2/28.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "ZBConfigItemObject.h"
@interface ZBConfigItemObject () <NSCoding>
@end


@implementation ZBConfigItemObject

- (id)init {
    if( self = [super init] ) {
        self.imSvrUrl = @"";
        self.httpSvrUrl = @"";
        self.mePageUrl = @"";
        self.manPageUrl = @"";
        self.minAavilableVer = 0;
        self.minAvailableMsg = @"";
        self.newestVer = 0;
        self.newestMsg = @"";
        self.downloadAppUrl = @"";
        self.svrList = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.imSvrUrl = [coder decodeObjectForKey:@"imSvrUrl"];
        self.httpSvrUrl = [coder decodeObjectForKey:@"httpSvrUrl"];
        self.mePageUrl = [coder decodeObjectForKey:@"mePageUrl"];
        self.manPageUrl = [coder decodeObjectForKey:@"manPageUrl"];
        self.minAavilableVer = [coder decodeIntForKey:@"minAavilableVer"];
        self.minAvailableMsg = [coder decodeObjectForKey:@"minAvailableMsg"];
        self.newestVer = [coder decodeIntForKey:@"newestVer"];
        self.newestMsg = [coder decodeObjectForKey:@"newestMsg"];
        self.downloadAppUrl = [coder decodeObjectForKey:@"downloadAppUrl"];
        self.svrList = [coder decodeObjectForKey:@"svrList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.imSvrUrl forKey:@"imSvrUrl"];
    [coder encodeObject:self.httpSvrUrl forKey:@"httpSvrUrl"];
    [coder encodeObject:self.mePageUrl forKey:@"mePageUrl"];
    [coder encodeObject:self.manPageUrl forKey:@"manPageUrl"];
    [coder encodeInt:self.minAavilableVer forKey:@"minAavilableVer"];
    [coder encodeObject:self.minAvailableMsg forKey:@"minAvailableMsg"];
    [coder encodeInt:self.newestVer forKey:@"newestVer"];
    [coder encodeObject:self.newestMsg forKey:@"newestMsg"];
    [coder encodeObject:self.downloadAppUrl forKey:@"downloadAppUrl"];
    [coder encodeObject:self.svrList forKey:@"svrList"];


}

@end
