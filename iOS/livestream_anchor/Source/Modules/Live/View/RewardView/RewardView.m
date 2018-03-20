//
//  RewardView.m
//  livestream
//
//  Created by randy on 2017/9/29.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "RewardView.h"
#import "LiveBundle.h"

#define RewardedTip @"Rewarded Credits: "
#define RestTimeTip @"Generated in: "

@interface RewardView()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger timeCount;
@property (nonatomic, strong) IMRebateItem *item;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *loadingBgView;

@property (weak, nonatomic) IBOutlet UILabel *rulesLabel;


@end

@implementation RewardView

- (void)dealloc {
    NSLog(@"RewardView::dealloc()");
    [self.timer invalidate];
    self.timer = nil;
}

- (void)stopTime {
    [self.timer invalidate];
    self.timer = nil;
}

+ (RewardView *) rewardView {
    
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    RewardView* rewardView = [nibs objectAtIndex:0];
    rewardView.loadingView.transform = CGAffineTransformMakeScale(3.0, 3.0);
    [rewardView.loadingView startAnimating];
    rewardView.loadingBgView.hidden = YES;
    rewardView.layer.cornerRadius = 5;
    rewardView.timeNumLabel.font = [UIFont boldSystemFontOfSize:19];
    rewardView.creditNumLabel.font = [UIFont boldSystemFontOfSize:19];
    rewardView.rulesLabel.text = NSLocalizedStringFromSelf(@"eRZ-DY-sV9.text");
    return rewardView;
}

- (void)setupTimeAndCredit:(IMRebateItem *)item {
    
    self.loadingBgView.hidden = YES;
    self.item = item;
    self.creditNumLabel.text = [NSString stringWithFormat:@"%.2f",item.curCredit];
    
    // 如果定时器存在 先移除
    if ( self.timer ) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timeCount = item.curTime;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeTimeLabel) userInfo:nil repeats:YES];
    [self.timer setFireDate:[NSDate distantPast]];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)updataCredit:(double)credit {
    self.creditNumLabel.text = [NSString stringWithFormat:@"%.2f",credit];
}

- (void)updataCurTime:(int)curTime {
    if ( self.timer ) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timeCount = curTime;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeTimeLabel) userInfo:nil repeats:YES];
    [self.timer setFireDate:[NSDate distantPast]];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)changeTimeLabel{
    self.timeNumLabel.text = [NSString stringWithFormat:@"%lds",(long)_timeCount];
    self.timeCount -= 1;
    
    if (self.timeCount < 0) {
        [self.timer invalidate]; // 关闭
        self.timer = nil;
        // 关闭之后，重设计数
        self.timeCount = self.item.preTime;
        self.loadingBgView.hidden = NO;
    }
}


// 关闭界面
- (IBAction)closeView:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardViewCloseAction:)]) {
        [self.delegate rewardViewCloseAction:self];
    }
}

- (NSAttributedString *)parseMessage:(NSString *)text font:(UIFont *)font color:(UIColor *)textColor {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttributes:@{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName:textColor
                                     }
                             range:NSMakeRange(0, attributeString.length)
     ];
    return attributeString;
}

@end
