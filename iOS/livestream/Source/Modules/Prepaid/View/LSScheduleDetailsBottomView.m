//
//  LSScheduleDetailsBottomView.m
//  livestream
//
//  Created by Randy_Fan on 2020/4/20.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleDetailsBottomView.h"

@implementation LSScheduleDetailsBottomView

+ (CGFloat)viewHeight {
    CGFloat height = 380;
    if (SCREEN_WIDTH > 320) {
        height = 350;
    }
    return height;;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSScheduleDetailsBottomView" owner:self options:0].firstObject;
    }
    return self;
}

- (IBAction)didHowWork:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didHowWorkAction)]) {
        [self.delegate didHowWorkAction];
    }
}


@end
