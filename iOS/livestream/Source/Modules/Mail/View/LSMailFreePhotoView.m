//
//  LSMailFreePhotoView.m
//  livestream
//
//  Created by Randy_Fan on 2019/1/8.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import "LSMailFreePhotoView.h"

@implementation LSMailFreePhotoView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        LSMailFreePhotoView *contenView = (LSMailFreePhotoView *)[[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;
        contenView.frame = frame;
        [contenView layoutIfNeeded];
        self = contenView;
    }
    return self;
}

- (void)activiViewIsShow:(BOOL)isShow {
    if (isShow) {
        [self.activityView startAnimating];
        self.activityView.hidden = NO;
    } else {
        [self.activityView stopAnimating];
        self.activityView.hidden = YES;
    }
}

@end
