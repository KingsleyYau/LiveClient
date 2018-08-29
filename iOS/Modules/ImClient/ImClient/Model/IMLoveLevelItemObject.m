//
//  IMLoveLevelItemObject.m
//  livestream
//
//  Created by Max on 2018/6/11.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "IMLoveLevelItemObject.h"

@implementation IMLoveLevelItemObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.loveLevel = [coder decodeIntForKey:@"loveLevel"];
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.anchorName = [coder decodeObjectForKey:@"anchorName"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.loveLevel forKey:@"loveLevel"];
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.anchorName forKey:@"anchorName"];

}


@end
