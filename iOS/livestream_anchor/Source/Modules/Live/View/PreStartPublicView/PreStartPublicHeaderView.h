//
//  PreStartPublicHeaderView.h
//  livestream_anchor
//
//  Created by test on 2018/3/2.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImageView.h"

@class PreStartPublicHeaderView;
@protocol PreStartPublicHeaderViewDelegate <NSObject>
@optional
- (void)preStartPublicHeaderViewCloseAction:(PreStartPublicHeaderView *)headView;
@end


@interface PreStartPublicHeaderView : UIView
@property (weak, nonatomic) IBOutlet GPUImageView *videoView;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) id<PreStartPublicHeaderViewDelegate> delegate;
+ (PreStartPublicHeaderView *)headerView;
- (void)setupVideoPlay;
- (void)startPreViewVideoPlay;
- (void)stopPreViewVideoPlay;
@end
