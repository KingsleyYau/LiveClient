//
//  LiveRoomConfigItemObject.m
//  dating
//
//  Created by Alex on 17/5/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LiveRoomConfigItemObject.h"
@interface LiveRoomConfigItemObject () <NSCoding>
@end


@implementation LiveRoomConfigItemObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.imSvr_ip = [coder decodeObjectForKey:@"imSvr_ip"];
        self.imSvr_port = [coder decodeIntForKey:@"imSvr_port"];
        self.httpSvr_ip = [coder decodeObjectForKey:@"httpSvr_ip"];
        self.httpSvr_port = [coder decodeIntForKey:@"httpSvr_port"];
        self.uploadSvr_ip = [coder decodeObjectForKey:@"uploadSvr_ip"];
        self.uploadSvr_port = [coder decodeIntForKey:@"uploadSvr_port"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.imSvr_ip  forKey:@"imSvr_ip"];
    [coder encodeInt:self.imSvr_port forKey:@"imSvr_port"];
    [coder encodeObject:self.httpSvr_ip  forKey:@"httpSvr_ip"];
    [coder encodeInt:self.httpSvr_port forKey:@"httpSvr_port"];
    [coder encodeObject:self.uploadSvr_ip  forKey:@"uploadSvr_ip"];
    [coder encodeInt:self.uploadSvr_port forKey:@"uploadSvr_port"];
}

@end
