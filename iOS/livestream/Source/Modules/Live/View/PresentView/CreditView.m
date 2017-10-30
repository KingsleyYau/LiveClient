//
//  CreditView.m
//  livestream
//
//  Created by randy on 2017/9/12.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "CreditView.h"
#import "LSLoginManager.h"
#import "LSImageViewLoader.h"
#import "LiveBundle.h"

#define BalanceTip @"My Balance: "

@implementation CreditView

+ (CreditView *) creditView {
    
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    CreditView* view = [nibs objectAtIndex:0];
    view.rechargeBtn.layer.cornerRadius = 4;
    view.rechargeBtn.layer.masksToBounds = YES;
    view.userHeadImageView.layer.cornerRadius = 30;
    view.userHeadImageView.layer.masksToBounds = YES;
    return view;
}

- (void)updateUserBalance:(double)credit {
    
    LSLoginManager *loginManager = [LSLoginManager manager];
    
    LSImageViewLoader *loader = [LSImageViewLoader loader];
    [loader loadImageWithImageView:self.userHeadImageView options:0 imageUrl:loginManager.loginItem.photoUrl placeholderImage:[UIImage imageNamed:@"Man_Head_Nomal"]];
    
    self.nameLabel.text = loginManager.loginItem.nickName;
    self.userIdLabel.text = [NSString stringWithFormat:@"ID:%@",loginManager.loginItem.userId];
    
    NSMutableAttributedString *attribuStr = [[NSMutableAttributedString alloc] init];
    [attribuStr appendAttributedString:[self parseMessage:BalanceTip font:[UIFont systemFontOfSize:12] color:[UIColor blackColor]]];
    NSString *str = [NSString stringWithFormat:@"%.2f credits",credit];
    [attribuStr appendAttributedString:[self parseMessage:str font:[UIFont systemFontOfSize:12] color:COLOR_WITH_16BAND_RGB(0xffd205)]];
    self.balanceLabel.attributedText = attribuStr;
}

- (IBAction)userRecharge:(id)sender {
    
    
}

- (IBAction)closeAction:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(creditViewCloseAction:)]) {
        [self.delegate creditViewCloseAction:self];
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
