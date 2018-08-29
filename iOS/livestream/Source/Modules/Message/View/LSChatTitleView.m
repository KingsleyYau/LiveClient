//
//  ChatTitleView.m
//  dating
//
//  Created by test on 16/5/17.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSChatTitleView.h"

@implementation LSChatTitleView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self =  [[NSBundle mainBundle] loadNibNamed:@"LSChatTitleView" owner:self options:nil].firstObject;
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.personIcon.layer.cornerRadius = self.personIcon.frame.size.height/2;
    self.personIcon.layer.masksToBounds = YES;
}

@end
