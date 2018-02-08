//
//  CreditView.h
//  livestream
//
//  Created by randy on 2017/9/12.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveRoom.h"
#import "LSUserInfoModel.h"

@class CreditView;
@protocol CreditViewDelegate <NSObject>
- (void)creditViewCloseAction:(CreditView *)creditView;
- (void)rechargeCreditAction:(CreditView *)creditView;
@end

@interface CreditView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *userHeadImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;

@property (weak, nonatomic) IBOutlet UIImageView *userLVImageView;

@property (weak, nonatomic) IBOutlet UIButton *rechargeBtn;

@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

/** 代理 */
@property (nonatomic, weak) id<CreditViewDelegate> delegate;

+ (CreditView *) creditView;

- (void)updateUserBalanceCredit:(double)credit userInfo:(LSUserInfoModel *)userInfo;

- (void)userLevelUp:(int)level;
- (void)userCreditChange:(double)credit;

// 跳转充值界面
- (IBAction)userRecharge:(id)sender;

@end
