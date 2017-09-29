//
//  CreditView.h
//  livestream
//
//  Created by randy on 2017/9/12.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveRoom.h"

@interface CreditView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *userHeadImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;

@property (weak, nonatomic) IBOutlet UIImageView *userLVImageView;

@property (weak, nonatomic) IBOutlet UIButton *rechargeBtn;

@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;


+ (CreditView *) creditView;

- (void)updateUserBalance:(double)credit;

// 跳转充值界面
- (IBAction)userRecharge:(id)sender;


@end
