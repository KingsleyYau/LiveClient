//
//  CreditView.m
//  livestream
//
//  Created by randy on 2017/9/12.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "CreditView.h"
#import "LoginManager.h"

#define BalanceTip @"My Balance: "

@implementation CreditView

+ (CreditView *) creditView {
    
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    CreditView* view = [nibs objectAtIndex:0];
    view.rechargeBtn.layer.cornerRadius = 6;
    view.rechargeBtn.layer.masksToBounds = YES;
    view.userHeadImageView.layer.cornerRadius = 30;
    view.userHeadImageView.layer.masksToBounds = YES;
    return view;
}

- (void)updateUserBalance:(double)credit {
    
    LoginManager *loginManager = [LoginManager manager];
    
    [self.userHeadImageView sd_setImageWithURL:[NSURL URLWithString:loginManager.loginItem.photoUrl] placeholderImage:[UIImage imageNamed:@"Man_Head_Nomal"] options:0];
    
    self.nameLabel.text = loginManager.loginItem.nickName;
    self.userIdLabel.text = [NSString stringWithFormat:@"ID:%@",loginManager.loginItem.userId];
    
//    self.userLVImageView.image = [UIImage imageNamed:loginManager.loginItem.level];
    
    NSMutableAttributedString *attribuStr = [[NSMutableAttributedString alloc] init];
    [attribuStr appendAttributedString:[self parseMessage:BalanceTip font:[UIFont systemFontOfSize:17] color:[UIColor blackColor]]];
    NSString *str = [NSString stringWithFormat:@"%.2f credits",credit];
    [attribuStr appendAttributedString:[self parseMessage:str font:[UIFont systemFontOfSize:17] color:COLOR_WITH_16BAND_RGB(0xffd205)]];
    self.balanceLabel.attributedText = attribuStr;
}

- (IBAction)userRecharge:(id)sender {
    
    
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
