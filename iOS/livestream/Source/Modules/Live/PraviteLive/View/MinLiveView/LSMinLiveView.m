//
//  LSMinLiveView.m
//  livestream
//
//  Created by Calvin on 2019/11/11.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSMinLiveView.h"

@interface LSMinLiveView ()

@end

@implementation LSMinLiveView

 - (instancetype)initWithFrame:(CGRect)frame {
     self = [super initWithFrame:frame];
     if (self) {
         LSMinLiveView *contenView = (LSMinLiveView *)[[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;
         contenView.frame = frame;
         [contenView layoutIfNeeded];
         self = contenView;
     }
     return self;
 }

- (IBAction)closeBtnDid:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(minLiveViewDidCloseBtn)]) {
        [self.delegate minLiveViewDidCloseBtn];
    }
}

- (IBAction)tapVideoView:(id)sender {
    if ([self.delegate respondsToSelector:@selector(minLiveViewDidVideo)]) {
        [self.delegate minLiveViewDidVideo];
    }
}

@end
