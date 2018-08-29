//
//  DialogTip.m
//  livestream
//
//  Created by randy on 2017/9/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "DialogTip.h"
#import "LiveBundle.h"
#import "LSTimer.h"

@interface DialogTip ()
@property (weak) UIView *view;
@property (nonatomic, strong) LSTimer *timer;
@end

@implementation DialogTip

+ (DialogTip *)dialogTip {

    static DialogTip *view;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
        view = [nibs objectAtIndex:0];
        view.layer.cornerRadius = 10;
        view.layer.masksToBounds = YES;
        view.tag = DialogTag;
        view.isShow = NO;
    });
    return view;
}

- (void)showDialogTip:(UIView *)view tipText:(NSString *)tip {
    if (self.isShow) {
        [self removeShow];
    }

    self.tipsLabel.text = tip;
    [view addSubview:self];
    [view bringSubviewToFront:self];

    
    if (self && view) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(view.mas_width).offset(-100);
            make.centerY.equalTo(view.mas_centerY);
            make.centerX.equalTo(view);
        }];
        
        self.isShow = YES;
        
        [self sizeToFit];
    }
    
    // 初始化倒数关闭直播间计时器
    self.timer = [[LSTimer alloc] init];
    WeakObject(self, weakSelf);
    [self.timer startTimer:nil timeInterval:3.0 * NSEC_PER_SEC starNow:NO action:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf removeShow];
        });
    }];
}

- (void)removeShow {
    self.isShow = NO;
    [self removeFromSuperview];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self stopTimer];
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer stopTimer];
        self.timer = nil;
    }
}

@end
