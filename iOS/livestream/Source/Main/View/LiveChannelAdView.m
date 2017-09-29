//
//  LiveChannelAdView.m
//  livestream
//
//  Created by test on 2017/9/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveChannelAdView.h"
#define AnimationTime 0.3

@interface LiveChannelAdView()
/** <#type#> */
@property (nonatomic, assign) CGFloat frameHeight;
@end

@implementation LiveChannelAdView


+ (instancetype)initWithLiveChannelAdViewXib:(id)owner {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamedWithFamily:@"LiveChannelAdView" owner:owner options:nil];
    LiveChannelAdView *adView = nibs.firstObject;
    adView.bounds = [UIScreen mainScreen].bounds;
    adView.frameHeight = adView.frame.size.height;
    adView.contentHeight.constant = screenSize.width + 88;
    adView.adViewDelegate = owner;
    adView.contentView.liveChannelDelegate = owner;
    [adView layoutIfNeeded];
    return adView;
}

- (void)awakeFromNib {
    [super awakeFromNib];


}


- (IBAction)clickToCloseAction:(id)sender {
//    [self hideAnimation];
    if ([self.adViewDelegate respondsToSelector:@selector(liveChannelAdView:didClickCloseBtn:)]) {
        [self.adViewDelegate liveChannelAdView:self didClickCloseBtn:sender];
    }

}


//显示界面
- (void)showAnimation
{
    
    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frameHeight);
    [UIView animateWithDuration:AnimationTime animations:^{
        self.contentView.alpha = 1;
        self.bgView.alpha = 0.8;
    }];
}

//隐藏界面
- (void)hideAnimation
{
    [UIView animateWithDuration:AnimationTime animations:^{
        self.bgView.alpha = 0;
        self.contentView.alpha = 0;
    }completion:^(BOOL finished) {
        self.frame = CGRectMake(0, 0, self.frame.size.width, 44);

    }];
}

- (IBAction)topBtnClickAction:(id)sender {
    
    if ([self.adViewDelegate respondsToSelector:@selector(liveChannelAdView:didClickTopToList:)]) {
        [self.adViewDelegate liveChannelAdView:self didClickTopToList:sender];
    }
}

@end
