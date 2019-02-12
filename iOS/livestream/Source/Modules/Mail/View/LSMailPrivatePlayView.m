//
//  LSMailPrivatePlayView.m
//  livestream
//
//  Created by Randy_Fan on 2018/12/13.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSMailPrivatePlayView.h"

@implementation LSMailPrivatePlayView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        LSMailPrivatePlayView *contenView = (LSMailPrivatePlayView *)[[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;
        contenView.frame = frame;
        [contenView layoutIfNeeded];
        self = contenView;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.stampsBuyBtn.layer.cornerRadius = 5;
    self.stampsBuyBtn.layer.masksToBounds = YES;
    self.creditsBuyBtn.layer.cornerRadius = 5;
    self.creditsBuyBtn.layer.masksToBounds = YES;
}

- (void)hideenAllView {
    self.videoPlayView.hidden = NO;
    self.representLabel.hidden = NO;
    self.buyVideoView.hidden = YES;
    self.noteLabel.hidden = YES;
    self.expiredView.hidden = YES;
    self.unlockPlayView.hidden = YES;
}

- (void)showBuyVideoView {
    self.videoPlayView.hidden = NO;
    self.buyVideoView.hidden = NO;
    self.noteLabel.hidden = NO;
    self.noteLabel.text = NSLocalizedStringFromSelf(@"Mgm-zg-QOo.text");
    self.representLabel.hidden = NO;
    self.expiredView.hidden = YES;
    self.unlockPlayView.hidden = YES;
}

- (void)showUnlockPlayView {
    self.videoPlayView.hidden = NO;
    self.unlockPlayView.hidden = NO;
    self.representLabel.hidden = NO;
    self.expiredView.hidden = YES;
    self.buyVideoView.hidden = YES;
    self.noteLabel.hidden = YES;
    self.noteLabel.text = @"";
    self.noteLabelTop.constant = 0;
    [self.videoPlayView bringSubviewToFront:self.videoImageView];
}

- (void)showExpiredView {
    self.videoPlayView.hidden = NO;
    self.expiredView.hidden = NO;
    self.representLabel.hidden = NO;
    self.unlockPlayView.hidden = YES;
    self.buyVideoView.hidden = YES;
    self.noteLabel.hidden = YES;
    self.noteLabel.text = @"";
    self.noteLabelTop.constant = 0;
}

- (void)activiViewIsShow:(BOOL)isShow {
    if (isShow) {
        [self.activiView startAnimating];
        self.activiView.hidden = NO;
    } else {
        [self.activiView stopAnimating];
        self.activiView.hidden = YES;
    }
}

- (IBAction)playByStampAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(mailPrivatePlayView:playByStamp:)]) {
        [self.delegate mailPrivatePlayView:self playByStamp:self.item];
    }
}

- (IBAction)playByCreditsAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(mailPrivatePlayView:playByCredits:)]) {
        [self.delegate mailPrivatePlayView:self playByCredits:self.item];
    }
}

- (IBAction)unlockPlayVideoAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(mailPrivatePlayView:unlockPlayVideo:)]) {
        [self.delegate mailPrivatePlayView:self unlockPlayVideo:self.item];
    }
}

@end
