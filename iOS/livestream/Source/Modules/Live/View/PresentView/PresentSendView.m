//
//  PresentSendView.m
//  UIWidget
//
//  Created by test on 2017/6/12.
//  Copyright © 2017年 lance. All rights reserved.
//

#import "PresentSendView.h"
#import "LiveBundle.h"

@interface PresentSendView()
@end

@implementation PresentSendView

static NSString *cellID = @"cellID";


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        NSBundle *bundle = [LiveBundle mainBundle];
        self.containerView = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:bundle] instantiateWithOwner:self options:nil].firstObject;
        CGRect newFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.containerView.frame = newFrame;
        self.containerView.layer.cornerRadius = 3.0f;
        self.containerView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xf7cd3a).CGColor;
        self.containerView.layer.borderWidth = 1;
        self.containerView.layer.masksToBounds = YES;
        [self addSubview:self.containerView];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

@end
