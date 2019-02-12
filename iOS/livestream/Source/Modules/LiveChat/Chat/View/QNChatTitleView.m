//
//  ChatTitleView.m
//  dating
//
//  Created by test on 16/5/17.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "QNChatTitleView.h"

@implementation QNChatTitleView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self =  [[LiveBundle mainBundle] loadNibNamed:@"QNChatTitleView" owner:self options:nil].firstObject;
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.personIcon.layer.cornerRadius = self.personIcon.frame.size.height * 0.5;
    self.personIcon.layer.masksToBounds = YES;
}

@end
