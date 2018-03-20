//
//  LiveChannelAdView.h
//  livestream
//
//  Created by test on 2017/9/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveChannelContentView.h"
@class LiveChannelAdView;
@protocol LiveChannelAdViewDelegate <NSObject>

@optional

- (void)liveChannelAdView:(LiveChannelAdView *)view didClickCloseBtn:(UIButton *)sender;
- (void)liveChannelAdView:(LiveChannelAdView *)view didClickTopToList:(UIButton *)sender;

@end

@interface LiveChannelAdView : UIView

@property (weak, nonatomic) IBOutlet LiveChannelContentView *contentView;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeight;

/** 代理 */
@property (nonatomic, weak) id<LiveChannelAdViewDelegate> adViewDelegate;
+ (instancetype)initWithLiveChannelAdViewXib:(id)owner;
- (void)showAnimation;
- (void)hideAnimation;
@end
