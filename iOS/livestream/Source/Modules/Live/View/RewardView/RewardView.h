//
//  RewardView.h
//  livestream
//
//  Created by randy on 2017/9/29.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMRebateItem.h"

@class RewardView;
@protocol RewardViewDelegate <NSObject>
- (void)rewardViewCloseAction:(RewardView *)creditView;
@end

@interface RewardView : UIView

@property (weak, nonatomic) IBOutlet UILabel *creditNumLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeNumLabel;

@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

/** 代理 */
@property (nonatomic, weak) id<RewardViewDelegate> delegate;

+ (RewardView *) rewardView;

- (void)setupTimeAndCredit:(IMRebateItem *)item;

- (void)updataCredit:(double)credit;

- (void)updataCurTime:(int)curTime;

- (IBAction)closeView:(id)sender;

- (void)stopTime;

@end
