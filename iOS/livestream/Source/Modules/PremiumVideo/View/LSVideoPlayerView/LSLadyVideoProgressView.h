//
//  LSLadyVideoProgressView.h
//  dating
//
//  Created by alex shum on 17/8/10.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LSLadyVideoProgressViewDelegate <NSObject>
- (void)ladyVideoProgressViewIsPlaying:(BOOL)isPause;
// 开始滑动
- (void)ladyVideoProgressViewTouchBegan:(UISlider *)sender;
// 滑动中
- (void)ladyVideoProgressViewTouchChanged:(UISlider *)sender;
// 结束滑动
- (void)ladyVideoProgressViewTouchEnded:(UISlider *)sender;
@end

@interface LSLadyVideoProgressView : UIView
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *ladyBeginLabel;
@property (weak, nonatomic) IBOutlet UISlider *videoSiider;
@property (weak, nonatomic) IBOutlet UILabel *ladyEndLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *beginTimeLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endTimeLabelWidth;
@property (weak, nonatomic) id <LSLadyVideoProgressViewDelegate> delegate;
- (void)setPlayButtonSelected;
- (void)hiddenPlayTime;
- (void)setPlaySuspendOrStart:(BOOL)isSuspend;
@end
