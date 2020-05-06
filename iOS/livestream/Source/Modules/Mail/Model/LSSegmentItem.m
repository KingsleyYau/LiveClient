//
//  LSSegmentItem.m
//  livestream
//
//  Created by test on 2020/4/3.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSSegmentItem.h"

@implementation LSSegmentItem

- (instancetype)init {
    if (self = [super init]) {
        self.lineSelectColor = kSelectedColor;
        self.textSelectColor = kTextSelectedColor;
        self.normalColor = kNormalColor;
        self.normalBgColor = kNormalBgColor;
        self.selectBgColor = kSelectBgColor;
    }
    return self;
}
@end
