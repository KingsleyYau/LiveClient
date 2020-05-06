//
//  LSMinLiveView.m
//  livestream
//
//  Created by Calvin on 2019/11/11.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSMinLiveView.h"
#import "LSShadowView.h"
@interface LSMinLiveView ()

@end

@implementation LSMinLiveView

- (instancetype)initWithFrame:(CGRect)frame {
     self = [super initWithFrame:frame];
     if (self) {
         self =  [[LiveBundle mainBundle] loadNibNamed:@"LSMinLiveView" owner:self options:nil].firstObject;
         self.frame = frame;
         
         
     }
     return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = 0.7;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1;
    
}

- (void)setNeedsLayout {
    [super setNeedsLayout];
    self.tx_size = CGSizeMake(122, 163);
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

- (IBAction)panVideoView:(UIPanGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(minLiveViewPan:)]) {
        [self.delegate minLiveViewPan:sender];
    }
}

@end
