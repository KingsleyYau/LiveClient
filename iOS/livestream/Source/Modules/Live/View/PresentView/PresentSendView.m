//
//  PresentSendView.m
//  UIWidget
//
//  Created by test on 2017/6/12.
//  Copyright © 2017年 lance. All rights reserved.
//

#import "PresentSendView.h"

@interface PresentSendView()
@end


@implementation PresentSendView

static NSString *cellID = @"cellID";


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        UIView *containerView = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] instantiateWithOwner:self options:nil].firstObject;
        CGRect newFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        containerView.frame = newFrame;
        containerView.layer.cornerRadius = 6.0f;
        containerView.layer.borderColor = [UIColor colorWithRed:12/255.0 green:237/255.0 blue:245/255.0 alpha:1].CGColor;
        containerView.layer.borderWidth = 1;
        containerView.layer.masksToBounds = YES;
        [self addSubview:containerView];
        

    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


@end
