//
//  LSScheduleListBottomView.m
//  livestream
//
//  Created by Randy_Fan on 2020/4/13.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleListBottomView.h"

@implementation LSScheduleListBottomView

+ (CGFloat)viewHeight {
    return 110;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSScheduleListBottomView" owner:self options:0].firstObject;
    }
    return self;
}

- (IBAction)howBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didHowWorkAction)]) {
        [self.delegate didHowWorkAction];
    }
}


@end
