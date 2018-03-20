//
//  MyCoinHeaderView.m
//  livestream
//
//  Created by test on 2017/12/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "MyCoinHeaderView.h"

@implementation MyCoinHeaderView



- (instancetype)init
{
    self = [super init];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil].firstObject;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil].firstObject;
        self.frame = frame;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}
@end
