//
//  LSHomeScheduleItem.m
//  livestream
//
//  Created by test on 2020/3/25.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSHomeScheduleItem.h"

@implementation LSHomeScheduleItem

- (instancetype)init {
    if (self = [super init]) {
        self.leftTime = 0;
        self.startTime = 0;
        self.startNum = 0;
        self.willStartNum = 0;
    }
    return self;
}

@end
