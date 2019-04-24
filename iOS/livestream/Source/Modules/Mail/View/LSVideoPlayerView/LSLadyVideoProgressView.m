//
//  LSLadyVideoProgressView.m
//  dating
//
//  Created by alex shum on 17/8/10.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSLadyVideoProgressView.h"

@implementation LSLadyVideoProgressView

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
    self.videoSiider.continuous = YES;
    // slider开始滑动事件
    [self.videoSiider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    // slider滑动中事件
    [self.videoSiider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    // slider结束滑动事件
    [self.videoSiider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    UIImage * image = [self OriginImage:[UIImage imageNamed:@"Mail_Video_Slider"] scaleToSize:CGSizeMake(14, 14)];
    [self.videoSiider setThumbImage:image forState:UIControlStateNormal];
}

- (IBAction)clickPlayOrPause:(UIButton *)sender {
    sender.selected = !sender.selected;
    UIImage *image = [[UIImage alloc] init];
    if (sender.selected) {
        image = [UIImage imageNamed:@"Mail_Video_Progress_Start"];
    } else {
        image = [UIImage imageNamed:@"Mail_Video_Progress_Suspend"];
    }
    [sender setImage:image forState:UIControlStateNormal];
    if ([self.delegate respondsToSelector:@selector(ladyVideoProgressViewIsPlaying:)]) {
        [self.delegate ladyVideoProgressViewIsPlaying:sender.selected];
    }
}

- (void)setPlayButtonSelected {
    [self clickPlayOrPause:self.playButton];
}

- (void)setPlaySuspendOrStart:(BOOL)isSuspend {
    self.playButton.selected = isSuspend;
    [self clickPlayOrPause:self.playButton];
}

- (void)hiddenPlayTime {
    self.beginTimeLabelWidth.constant = 0;
    self.endTimeLabelWidth.constant = 0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

/*
 对原来的图片的大小进行处理
 @param image 要处理的图片
 @param size  处理过图片的大小
 */
- (UIImage *)OriginImage:(UIImage *)image scaleToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage *scaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImage;
}

#pragma mark - 滑动动作
- (void)progressSliderTouchBegan:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(ladyVideoProgressViewTouchBegan:)]) {
        [self.delegate ladyVideoProgressViewTouchBegan:sender];
    }
}

- (void)progressSliderValueChanged:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(ladyVideoProgressViewTouchChanged:)]) {
        [self.delegate ladyVideoProgressViewTouchChanged:sender];
    }
}

- (void)progressSliderTouchEnded:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(ladyVideoProgressViewTouchEnded:)]) {
        [self.delegate ladyVideoProgressViewTouchEnded:sender];
    }
}

@end
