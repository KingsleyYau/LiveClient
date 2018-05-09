//
//  IMAnchorUserInfoItemObject.m
//  livestream
//
//  Created by Max on 2018/4/10
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "IMAnchorUserInfoItemObject.h"

@implementation IMAnchorUserInfoItemObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.riderId = [coder decodeObjectForKey:@"riderId"];
        self.riderName = [coder decodeObjectForKey:@"riderName"];
        self.riderUrl = [coder decodeObjectForKey:@"riderUrl"];
        self.honorImg = [coder decodeObjectForKey:@"honorImg"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.riderId forKey:@"riderId"];
    [coder encodeObject:self.riderName forKey:@"riderName"];
    [coder encodeObject:self.riderUrl forKey:@"riderUrl"];
    [coder encodeObject:self.honorImg forKey:@"honorImg"];

}


@end
