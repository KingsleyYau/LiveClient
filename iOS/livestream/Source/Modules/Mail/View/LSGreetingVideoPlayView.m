//
//  LSGreetingVideoPlayView.m
//  livestream
//
//  Created by Randy_Fan on 2018/11/28.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSGreetingVideoPlayView.h"
#import "LSImageViewLoader.h"

@interface LSGreetingVideoPlayView()

@end

@implementation LSGreetingVideoPlayView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        LSGreetingVideoPlayView *contenView = (LSGreetingVideoPlayView *)[[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;
        contenView.frame = frame;
        [contenView layoutIfNeeded];
        self = contenView;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setupDetail {
    if (self.item) {
        self.videoTimeLabel.text = [self timeFormatted:floor(self.item.videoTime)];
        [[LSImageViewLoader loader] loadImageWithImageView:self.videoCoverImageView options:0 imageUrl:self.item.videoCoverUrl placeholderImage:nil];
    }
}

- (NSString *)timeFormatted:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
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

- (IBAction)noReplyReplayAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(greetingVideoPlayView:noReplyReplayVideo:)]) {
        [self.delegate greetingVideoPlayView:self noReplyReplayVideo:self.item];
    }
}

- (IBAction)replyAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(greetingVideoPlayView:replyGreeting:)]) {
        [self.delegate greetingVideoPlayView:self replyGreeting:self.item];
    }
}

- (IBAction)isReplyReplayAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(greetingVideoPlayView:isReplyReplayVideo:)]) {
        [self.delegate greetingVideoPlayView:self isReplyReplayVideo:self.item];
    }
}


@end
