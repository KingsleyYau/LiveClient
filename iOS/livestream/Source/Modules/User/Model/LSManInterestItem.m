//
//  ManInterestItem.m
//  dating
//
//  Created by test on 2017/5/5.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSManInterestItem.h"

@implementation LSManInterestItem

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.title = dict[@"title"];
        self.icon = dict[@"icon"];
    }
    return self;
}

@end
