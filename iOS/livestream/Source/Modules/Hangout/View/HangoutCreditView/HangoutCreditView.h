//
//  HangoutCreditView.h
//  livestream
//
//  Created by randy on 2017/9/12.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveRoom.h"
#import "LSUserInfoModel.h"

@class HangoutCreditView;
@protocol HangoutCreditViewDelegate <NSObject>
- (void)creditViewCloseAction:(HangoutCreditView *)creditView;
- (void)rechargeCreditAction:(HangoutCreditView *)creditView;
@end

@interface HangoutCreditView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *userHeadImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;

@property (weak, nonatomic) IBOutlet UIImageView *userLVImageView;

@property (weak, nonatomic) IBOutlet UIButton *rechargeBtn;

@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

/** 代理 */
@property (nonatomic, weak) id<HangoutCreditViewDelegate> delegate;

+ (HangoutCreditView *) creditView;

- (void)updateUserBalanceCredit:(double)credit userInfo:(LSUserInfoModel *)userInfo;

- (void)userLevelUp:(int)level;
- (void)userCreditChange:(double)credit;

// 跳转充值界面
- (IBAction)userRecharge:(id)sender;

@end
