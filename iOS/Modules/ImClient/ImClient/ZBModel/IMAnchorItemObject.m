//
//  IMAnchorItemObject.m
//  livestream
//
//  Created by Max on 2018/4/9.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "IMAnchorItemObject.h"

@implementation IMAnchorItemObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.anchorNickName = [coder decodeObjectForKey:@"anchorNickName"];
         self.anchorPhotoUrl = [coder decodeObjectForKey:@"anchorPhotoUrl"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.anchorNickName forKey:@"anchorNickName"];
    [coder encodeObject:self.anchorPhotoUrl forKey:@"anchorPhotoUrl"];

}


@end
