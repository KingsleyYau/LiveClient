//
//  LSVideoProgressView.m
//  dating
//
//  Created by Calvin on 17/6/29.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSVideoProgressView.h"

@interface LSVideoProgressView ()

@end

@implementation LSVideoProgressView

- (instancetype)init{
    if (self = [super init]) {
        self = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;
        self.frame = frame;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (IBAction)didPlayButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setImage:[UIImage imageNamed:@"Greeting_Video_Play"] forState:UIControlStateNormal];
    } else {
        [sender setImage:[UIImage imageNamed:@"EMF_Video_Pause"] forState:UIControlStateNormal];
    }
    if ([self.delegate respondsToSelector:@selector(videoProgressViewIsPlaying:)]) {
        [self.delegate videoProgressViewIsPlaying:sender.selected];
    }
}

- (void)setPlayButtonSelected {
    [self didPlayButton:self.playButton];
}

@end
