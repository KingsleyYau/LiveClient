//
//  ShareView.m
//  livestream
//
//  Created by randy on 2017/12/27.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "ShareView.h"
#import "LiveBundle.h"

@implementation ShareView

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSBundle *bundle = [LiveBundle mainBundle];
        UIView *containerView = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:bundle] instantiateWithOwner:self options:nil].firstObject;
        CGRect newFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        containerView.frame = newFrame;
        containerView.backgroundColor = COLOR_WITH_16BAND_RGB_ALPHA(0x00000000);
        [self addSubview:containerView];
        
        self.backgroundColor = COLOR_WITH_16BAND_RGB_ALPHA(0xe3000000);
    }
    return self;
}

- (IBAction)facebookAction:(id)sender {
    if ([self.delagate respondsToSelector:@selector(facebookShareAction:)]) {
        [self.delagate facebookShareAction:self];
    }
}


- (IBAction)copyLinkAction:(id)sender {
    if ([self.delagate respondsToSelector:@selector(copyLinkShareAction:)]) {
        [self.delagate copyLinkShareAction:self];
    }
}

- (IBAction)moreAction:(id)sender {
    if ([self.delagate respondsToSelector:@selector(moreShareAction:)]) {
        [self.delagate moreShareAction:self];
    }
}

@end
