//
//  LSScheduleDetailInfoItem.m
//  livestream
//
//  Created by test on 2020/3/31.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleDetailInfoItem.h"

@implementation LSScheduleDetailInfoItem

- (instancetype)init {
    self = [super init];
    if (self) {
        self.anchorName = @"";
        self.photoUrl = @"";
        self.detailType = LSScheduleDetailTypeUnknow;
    }
    return self;
}


@end
