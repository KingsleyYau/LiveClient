//
//  ChatTitleView.m
//  dating
//
//  Created by test on 16/5/17.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatTitleView.h"

@implementation ChatTitleView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self =  [[NSBundle mainBundle] loadNibNamed:@"ChatTitleView" owner:self options:nil].firstObject;
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}
@end
