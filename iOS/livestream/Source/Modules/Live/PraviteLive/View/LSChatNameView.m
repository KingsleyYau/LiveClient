//
//  LSChatNameView.m
//  livestream
//
//  Created by Randy_Fan on 2019/8/29.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSChatNameView.h"

@implementation LSChatNameView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        LSChatNameView *contenView = (LSChatNameView *)[[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;
        contenView.frame = frame;
        [contenView layoutIfNeeded];
        self = contenView;
    }
    return self;
}

+ (CGFloat)viewWidth:(CGFloat)textWidth {
    return textWidth + 6;
}

@end
