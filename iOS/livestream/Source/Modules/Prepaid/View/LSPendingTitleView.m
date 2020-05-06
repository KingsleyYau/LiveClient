//
//  LSPendingTitleView.m
//  livestream
//
//  Created by Randy_Fan on 2020/4/14.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSPendingTitleView.h"

@implementation LSPendingTitleView

+ (CGFloat)viewHeight {
    return 23;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSPendingTitleView" owner:self options:0].firstObject;
    }
    return self;
}

@end
