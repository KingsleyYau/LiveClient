//
//  IMOngoingShowItemObject.m
//  livestream
//
//  Created by Max on 2018/5/7.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "IMOngoingShowItemObject.h"

@implementation IMOngoingShowItemObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.showInfo = [coder decodeObjectForKey:@"showInfo"];
        self.type = [coder decodeIntForKey:@"type"];
        self.msg = [coder decodeObjectForKey:@"msg"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.showInfo forKey:@"showInfo"];
    [coder encodeInt:self.type forKey:@"type"];
    [coder encodeObject:self.msg forKey:@"msg"];

}


@end
