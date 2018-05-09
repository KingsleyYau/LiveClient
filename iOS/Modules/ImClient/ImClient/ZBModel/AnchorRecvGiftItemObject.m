//
//  AnchorRecvGiftItemObject.m
//  livestream
//
//  Created by Max on 2018/4/9.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "AnchorRecvGiftItemObject.h"

@implementation AnchorRecvGiftItemObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.userId = [coder decodeObjectForKey:@"userId"];
        self.buyforList = [coder decodeObjectForKey:@"buyforList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.buyforList forKey:@"buyforList"];

}


@end
